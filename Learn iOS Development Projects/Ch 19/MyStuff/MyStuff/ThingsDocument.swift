//
//  ThingsDocument.swift
//  MyStuff
//
//  Created by James Bucanek on 10/4/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

let ThingsDocumentName = "Things I Own.mystuff"


protocol ThingsDocumentDelegate {
    func gotThings(document: ThingsDocument)
}

protocol ImageStorage {
    func keyForImage(newImage: UIImage?, existingKey: String?) -> String?
    func imageForKey(key: String?) -> UIImage?
}


class ThingsDocument: UIDocument, ImageStorage {
    
    var delegate: ThingsDocumentDelegate?
    
    class var documentURL: NSURL {
        // The "Things" document has a fixed name and is always stored in the ~/Documents,
        //	folder, located inside the app's local sandbox.
        let fileManager = NSFileManager.defaultManager()
        // Locate the standard "Documents" directory
        if let documentsDirURL = fileManager.URLForDirectory( .DocumentDirectory,
                                                    inDomain: .UserDomainMask,
                                           appropriateForURL: nil,
                                                      create: true,
                                                       error: nil) {
            // Add to that, the package name of the document and return it
            return documentsDirURL.URLByAppendingPathComponent(ThingsDocumentName)
        }
        assertionFailure("Unable to determine document storage location")
    }
    
    class func document(atURL url: NSURL = ThingsDocument.documentURL) -> ThingsDocument {
        // Return a UIDocument for the existing package at |url|, or create a new one
        // While url is a parameter which might change the in fugure, the default is the one
        //  and only ThingsDocument.documentURL
        let fileManager = NSFileManager.defaultManager()
        // Create the document object
        if let document = ThingsDocument(fileURL: ThingsDocument.documentURL) {
            if fileManager.fileExistsAtPath(url.path!) {
                // Document package already exists: open it
                document.openWithCompletionHandler() { (success) in
                    if success {
                        document.delegate?.gotThings(document)
                    }
                }
            } else {
                // Document package does not exit: create it
                // This is accomplished by saving the empty ThingsDocument, creating
                //  a new file package.
                document.saveToURL(url, forSaveOperation: .ForCreating, completionHandler: nil)
            }
            return document
        }
        assertionFailure("Unable to create ThingsDocument for \(url)")
    }
    
    // MARK: Lifecycle
    
    override init?(fileURL url: NSURL) {
        super.init(fileURL: url)
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "thingsDidChange:", name: WhatsitDidChangeNotification, object: nil)
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    
    // MARK: Document Content
    
    let thingsPreferredName = "things.data"
    let imagePreferredName = "image.png"
    
    var docWrapper = NSFileWrapper(directoryWithFileWrappers: [:])  // working top-level file wrapper
    
    override func contentsForType(typeName: String, error outError: NSErrorPointer) -> AnyObject? {
        // Called by UIDocument when it wants to save a document.
        // Return the data to be written.
        
        // The returned data can be as simple as an NSData object, but in this
        //	implementation you return an NSFileWrapper that describes multiple files
        //	to be saved in a package (folder). One of those files is an archived version
        //	of the things array (things.data). The rest of the files are PNG images.

        //
        // Serialize the array of MyWhatsit objects and store that as a file wrapper
        //
        
        if let wrapper = docWrapper.fileWrappers[thingsPreferredName] as? NSFileWrapper {
            // The existing document wrapper already contains a file wrapper for the things data.
            // Remove it so it can be replaced.
            // (To replace a file wrapper you must first delete the existing one; adding
            //  a file wrapper with the same name will NOT replace an existing wrapper.)
            docWrapper.removeFileWrapper(wrapper)
        }
        
        // Archive (serialize) the things array and add it to the package.
        let thingsData = NSKeyedArchiver.archivedDataWithRootObject(things)

        // Add the serialized data as a regular files wrapper. Since the code just
        //	checked for (and deleted) any file wrapper with that name, the
        //	key for this file wrapper will be the same as its preferred name.
        docWrapper.addRegularFileWithContents(thingsData, preferredFilename: thingsPreferredName)
        
        // Return the root file wrapper, which UIDocument will use to store the document.
        return docWrapper
    }
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        if let contentWrapper = contents as? NSFileWrapper {
            if let thingsWrapper = contentWrapper.fileWrappers[thingsPreferredName] as? NSFileWrapper {
                if let data = thingsWrapper.regularFileContents {
                    things = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [MyWhatsit]
                    for thing in things {
                        thing.imageStorage = self
                    }
                    docWrapper = contentWrapper            // Save the working document directory wrapper
                    return true
                }
            }
        }
        // For whatever reason, the document could not be loaded
        return false
    }

    // MARK: Data Model
    
    var things = [MyWhatsit]()                                      // the data model

    var whatsitCount: Int {
        return things.count
    }
    
    func whatsitAtIndex(index: Int) -> MyWhatsit {
        return things[index]
    }
    
    func indexOfWhatsit(thing: MyWhatsit) -> Int? {
        // Return the index in the collection of the given object,
        //  or nil if this objects is not a member.
        for (index,value) in enumerate(things) {
            if value === thing {
                return index
            }
        }
        return nil
    }
    
    func removeWhatsitAtIndex(index: Int) {
        // Remove the MyWhatsit object at the given index
        let thing = whatsitAtIndex(index)
        thing.willRemoveFromStorage()       // let the object know it is about to be removed from the document
        thing.imageStorage = nil
        things.removeAtIndex(index)
        updateChangeCount(.Done)
    }
    
    func anotherWhatsit() -> (object: MyWhatsit, index: Int) {
        // Create a new MyWhatsit object, insert it into the collection, and return
        //  it and the index it now occupies in the collection.
        let newThing = MyWhatsit(name: "My Item \(whatsitCount+1)")
        newThing.imageStorage = self
        things.append(newThing)
        updateChangeCount(.Done)
        return (newThing, things.count-1)
    }
    
    func thingsDidChange(notification: NSNotification) {
        if indexOfWhatsit(notification.object as MyWhatsit) != nil {
            updateChangeCount(.Done)
        }
    }
    
    // MARK: Image Storage
    
    func keyForImage(newImage: UIImage?, existingKey: String?) -> String? {
        // |image| is the new image to store in the document.
        // The image is converted into data stream suitable for persistent
        //  storage. A new file package is created for it and it's added
        //  to the docWrapper using the preferred name for images.
        // If that name is not uique, the wrapper will assign it a unique key.
        //
        // If |existingKey| is not nil, it's the key the image was previously stored under.
        //  This previous image file package is first deleted before adding
        //  the new one.
        //
        // The image's unique key is then returned to the caller.
        //
        // If |image| is nil, no image is stored and any previously stored image
        //  is removed. In this case, the function returns nil.
        
        if let key = existingKey {
            // An image wrapper with this key might already exist.
            // Delete it first.
            if let wrapper = docWrapper.fileWrappers[key] as? NSFileWrapper {
                docWrapper.removeFileWrapper(wrapper)
            }
        }
        
        var newKey: String? = nil
        if let image = newImage {
            // Compress the image using the PNG format
            let imageData = UIImagePNGRepresentation(image)
            // Add it to the document wrapper
            newKey = docWrapper.addRegularFileWithContents(imageData, preferredFilename: imagePreferredName)
        }
        
        // Either storing or erasing an image changes the document
        updateChangeCount(.Done)
        
        return newKey
    }

    func imageForKey(imageKey: String?) -> UIImage? {
        // Find the file wrapper for the given key, read its data, and turn
        //	that data back into a UIImage object.
        if let key = imageKey {
            if let wrapper = docWrapper.fileWrappers[key] as? NSFileWrapper {
                return UIImage(data: wrapper.regularFileContents!)
            }
        }
        return nil
    }
    
}

