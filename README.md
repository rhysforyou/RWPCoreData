# RWPCoreData

Core Data is a great framework, but it also requires you to write a hefty amount of boilerplate code for even the simplest of projects. RWPCoreData aims to solve some of the headaches associated with using Core Data in new projects through a few core features:

- The ability to instantiate managed objects via an `init` or `initWithContext:` method
- Creation and management of a main managed object context
- Automatic loading of your data model from `.xcdatamodeld` files present in your project
- Simplified of communication with remote APIs

## Classes

The library provides two main classes which your managed objects should inherit from:

- [**RWPManagedObject**](http://cocoadocs.org/docsets/RWPCoreData/0.8.0/Classes/RWPManagedObject.html) which provides easier instantiation, a main context, and so on. Classes should inherit from this if they aren't loaded from an external API.
- [**RWPRemoteManagedObject**](http://cocoadocs.org/docsets/RWPCoreData/0.8.0/Classes/RWPRemoteManagedObject.html) makes a few assumptions about external APIs that make it easier to serialise API responses into objects.
