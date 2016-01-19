#Installation

Grab the latest code version from [GitHub](https://github.com/joelrfcosta/x-team-discount-ascii-warehouse.git):

	$ git clone https://github.com/joelrfcosta/x-team-discount-ascii-warehouse.git

Or download using [this link](https://github.com/joelrfcosta/x-team-discount-ascii-warehouse/archive/master.zip)

##Dependencies
To be able to compile this project you need the following installed on your system.

###XCode
To be able to compile the code you need to have XCode 7.2 and iOS 9.0 installed.

###CocoaPods

This project uses [CocoaPods](https://cocoapods.org) as dependency manager to install and maintain third party libraries.
To [install CocoaPods](https://cocoapods.org/#install) run the following in the OS terminal:
	
	$ sudo gem install cocoapods

###Mogenerator
If you have [Homebrew](http://brew.sh) just run the following command to install the Mogenerator tool:

	$ brew install mogenerator

if not just follow the instructions on [Mogenerator](https://github.com/rentzsch/mogenerator) github page.

#Notes

##Core Data
[Core Data](https://developer.apple.com/library/tvos/documentation/Cocoa/Conceptual/CoreData/index.html) is used to manage the model layer objects on the application. With this structure I'm able to maintain the view controllers synchronized as soon as the model is updated.

I used two distinct managed object contexts: one is the `main` context with a persistent coordinator (to be able to save to "disk") and the other is a `private` one with the `main` managed object context as `parent`. This allows core data modifications on the private context without triggering notifications (and UI updates) until it is merged with the parent.

##Mogenerator
[Core Data](https://developer.apple.com/library/tvos/documentation/Cocoa/Conceptual/CoreData/index.html) is used to manage the model layer objects on the application but it has a limitation when we need to extend the objects. To fix this limitation and be able to easily change and maintain the Core Data classes I've used the [Mogenerator](https://github.com/rentzsch/mogenerator) tool.

##CocoaLumberjack
[CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) is a fast & simple, yet powerful & flexible logging framework for iOS. This should be used instead NSLog!

##AFNetworking
AFNetworking is a delightful networking library for iOS. It's built on top of the Foundation URL Loading System, extending the powerful high-level networking abstractions built into Cocoa. It has a modular architecture with well-designed, feature-rich APIs that are a joy to use.

##Collection View Controller
I've chosen collection view controller to display the data because of the distinct cell widths and the flexibility it brings to cell arrangement.

##Singletons
Singletons restricts the instantiation of a class to one object, this is a good pattern design to use when we need to coordinate actions across the application. I've used this pattern on `communication manager` and `core data manager`.

#Recommendations

##Documentation
Even if it is easy to read the project code it lacks documentation and it should be added as soon as possible. 

##Remote logging
Is should be possible to send the logs to a remote service, for example [Logentries](https://logentries.com). To be able to do this it is necessary to implement an CocoaLumberjack extension 


