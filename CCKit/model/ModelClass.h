//
//  ModelClass.h
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCModel.h"
#import <objc/runtime.h>

// Type Encodings
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
typedef NS_OPTIONS(NSUInteger, CCEncodingType) {
    CCEncodingTypeMask = 0xff,
    CCEncodingTypeChar = 0,
    CCEncodingTypeInt = 1,
    CCEncodingTypeShort = 2,
    CCEncodingTypeLong = 3,
    CCEncodingTypeLongLong = 4,
    CCEncodingTypeUnsignedChar = 5,
    CCEncodingTypeUnsignedInt = 6,
    CCEncodingTypeUnsignedShort = 7,
    CCEncodingTypeUnsignedLong = 8,
    CCEncodingTypeUnsignedLongLong = 9,
    CCEncodingTypeFloat = 10,
    CCEncodingTypeDouble = 11,
    CCEncodingTypeBool = 12, /// C++ bool or C99 _Bool
    CCEncodingTypeVoid = 13,
    CCEncodingTypeCharacterString = 14,/// char *
    CCEncodingTypeObject = 15,
    CCEncodingTypeClassObject = 16,
    CCEncodingTypeMethodSelector = 17,
    CCEncodingTypeArray = 18,
    CCEncodingTypeStruct = 19,
    CCEncodingTypeUnion = 20,
    CCEncodingTypebnum = 21,
    CCEncodingTypePointer = 22,
    CCEncodingTypeUnknown = 23,
    
    CCEncodingTypePropertyMask = 0xff00,
    CCEncodingTypePropertyReadonly = 1 << 8,
    CCEncodingTypePropertyCopy = 1 << 9,
    CCEncodingTypePropertyRetain = 1 << 10,
    CCEncodingTypePropertyNonatomic = 1 << 11,
    CCEncodingTypePropertyCustomGetter = 1 << 12,
    CCEncodingTypePropertyCustomSetter = 1 << 13,
    CCEncodingTypePropertyDynamic = 1 << 14,
    CCEncodingTypePropertyWeak = 1 << 15,
};

typedef NS_ENUM(NSUInteger, CCObjectType) {
    CCObjectTypeNSString,
    CCObjectTypeNSMutableString,
    CCObjectTypeNSNumber,
    CCObjectTypeNSDecimalNumber,
    CCObjectTypeNSNull,
    CCObjectTypeNSURL,
    CCObjectTypeNSDate,
    CCObjectTypeNSArray,
    CCObjectTypeNSMutableArray,
    CCObjectTypeNSDictionary,
    CCObjectTypeNSMutableDictionary,
    CCObjectTypeNotSupport,
};

/**
 When represents a NSArray, classObj and valueClassObj would be used. classObj is [NSArray class].
 All the values must have the same class, `valueClassObj` indicates their class.
 
 When represents a NSDictionary, all the three properties would be used. classObj is [NSDictionary class].
 1.If all the values are the same class, the `valueClassObj` indicates the class of value.
 2.If there values aren't the same type, `keyToClass` indicates the class for each value of corresponding key.
 
 If neither NSArray nor NSDictionary, it's not a container, just set `classObj`.
 */
@interface ContainerTypeObject : NSObject
/// type
@property (nonatomic, readonly) Class classObj;
/// value class
@property (nonatomic) ContainerTypeObject *valueClassObj;
/// all the values have the same class
@property (nonatomic) NSDictionary<NSString *, ContainerTypeObject *> *keyToClass;

+ (id)containerTypeObjectWithClass:(Class)classObj;
+ (id)arrayContainerTypeObjectWithValueClass:(Class)valueClass;
+ (id)dictionaryContainerTypeObjectWithValueClass:(Class)valueClass;
+ (id)dictionaryContainerTypeObjectWithKeyToValueClass:(NSDictionary<NSString *, ContainerTypeObject *> *)valueClass;

- (id)initWithClass:(Class)classObj;

@end

extern CCEncodingType CCEncodingTypeFromChar(const char *ptype);
extern CCEncodingType CCEncodingPropertyType(CCEncodingType type);
extern CCObjectType CCObjectTypeFromClass(Class classObj);

extern BOOL isNumberTypeOfEncodingType(CCEncodingType type);
extern BOOL isObjectTypeOfEncodingType(CCEncodingType type);
extern BOOL isContainerTypeForObjectType(CCObjectType type);


@class CCProperty;
@interface CCClass : NSObject

@property (nonatomic, readonly) CCClass *superClass;

/// property key to CCProperty, not property name
@property (nonatomic, readonly) NSDictionary<NSString *, CCProperty *> *properties;

/// black list property name
@property (nonatomic, readonly) NSSet<NSString *> *propertyNameBlackList;

/// hash property name
@property (nonatomic, readonly) NSSet<NSString *> *propertyNameCalculateHash;

/// map from propertyName to jsonKey
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *propertyNameToJsonKeyMap;

/// map from propertyName to ContainerTypeObject
@property (nonatomic, readonly) NSDictionary<NSString *, ContainerTypeObject *> *propertyNameToContainerTypeObjectMap;

+ (CCClass *)classWithClassObject:(Class)classObject;

@end

@interface CCProperty : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *jsonKey;
@property (nonatomic) CCEncodingType encodingType;
@property (nonatomic) CCObjectType objectType;
@property (nonatomic, strong) Class propertyClass;
@property (nonatomic) SEL getter;
@property (nonatomic) SEL setter;

+ (CCProperty *)propertyWithRuntime:(objc_property_t)objc_property;

@end
