//
//  ModelClass.m
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ModelClass.h"

CCEncodingType CCEncodingTypeFromChar(const char *ptype) {
    char type = ptype[0];
    CCEncodingType encodingType = CCEncodingTypeUnknown;
    switch (type) {
        case 'c':// A char
            encodingType = CCEncodingTypeChar;
            break;
        case 'i':// A int
            encodingType = CCEncodingTypeInt;
            break;
        case 's':// A short
            encodingType = CCEncodingTypeShort;
            break;
        case 'l':// A long, l is treated as a 32-bit quantity on 64-bit programs.
            encodingType = CCEncodingTypeLong;
            break;
        case 'q':// A long long
            encodingType = CCEncodingTypeLongLong;
            break;
        case 'C':// An unsigned char
            encodingType = CCEncodingTypeUnsignedChar;
            break;
        case 'I':// An unsigned int
            encodingType = CCEncodingTypeUnsignedInt;
            break;
        case 'S':// An unsigned short
            encodingType = CCEncodingTypeUnsignedShort;
            break;
        case 'L':// An unsigned long
            encodingType = CCEncodingTypeUnsignedLong;
            break;
        case 'Q':// An unsigned long long
            encodingType = CCEncodingTypeUnsignedLongLong;
            break;
        case 'f':// A float
            encodingType = CCEncodingTypeFloat;
            break;
        case 'd':// A double
            encodingType = CCEncodingTypeDouble;
            break;
        case 'B':// A C++ bool or a C99 _Bool, BOOL and bool are all B.
            encodingType = CCEncodingTypeBool;
            break;
        case 'v':// A void
            encodingType = CCEncodingTypeVoid;
            break;
        case '*':// A character string(char *)
            encodingType = CCEncodingTypeCharacterString;
            break;
        case '@':// An object
            encodingType = CCEncodingTypeObject;
            break;
        case '#':// A class object (Class)
            encodingType = CCEncodingTypeClassObject;
            break;
        case ':':// A method selector
            encodingType = CCEncodingTypeMethodSelector;
            break;
        case '[':// An array
            encodingType = CCEncodingTypeArray;
            break;
        case '{':// A structure
            encodingType = CCEncodingTypeStruct;
            break;
        case '(':// A union
            encodingType = CCEncodingTypeUnion;
            break;
        case 'b':// A bit field of num bits
            encodingType = CCEncodingTypebnum;
            break;
        case '^':// A pointer to type
            encodingType = CCEncodingTypePointer;
            break;
        default:
            encodingType = CCEncodingTypeUnknown;
            break;
    }
    return encodingType;
}

CCEncodingType CCEncodingPropertyType(CCEncodingType type) {
    return type & CCEncodingTypePropertyMask;
}

CCObjectType CCObjectTypeFromClass(Class classObj) {
    if (classObj == [NSString class]) {
        return CCObjectTypeNSString;
    } else if (classObj == [NSMutableString class]) {
        return CCObjectTypeNSMutableString;
    } else if (classObj == [NSNumber class]) {
        return CCObjectTypeNSNumber;
    } else if (classObj == [NSDecimalNumber class]) {
        return CCObjectTypeNSDecimalNumber;
    } else if (classObj == [NSNull class]) {
        return CCObjectTypeNSNull;
    } else if (classObj == [NSURL class]) {
        return CCObjectTypeNSURL;
    } else if (classObj == [NSDate class]) {
        return CCObjectTypeNSDate;
    } else if (classObj == [NSArray class]) {
        return CCObjectTypeNSArray;
    } else if (classObj == [NSMutableArray class]) {
        return CCObjectTypeNSMutableArray;
    } else if (classObj == [NSDictionary class]) {
        return CCObjectTypeNSDictionary;
    } else if (classObj == [NSMutableDictionary class]) {
        return CCObjectTypeNSMutableDictionary;
    }
    return CCObjectTypeNotSupport;
}

BOOL isNumberTypeOfEncodingType(CCEncodingType type) {
    type = CCEncodingTypeMask & type;
    if (type >= CCEncodingTypeChar && type <= CCEncodingTypeBool) {
        return YES;
    }
    return NO;
}

BOOL isObjectTypeOfEncodingType(CCEncodingType type) {
    type = CCEncodingTypeMask & type;
    return type == CCEncodingTypeObject;
}

BOOL isContainerTypeForObjectType(CCObjectType type) {
    type = CCEncodingTypeMask & type;
    if (type == CCObjectTypeNSArray ||
        type == CCObjectTypeNSMutableArray ||
        type == CCObjectTypeNSDictionary ||
        type == CCObjectTypeNSMutableDictionary) {
        return YES;
    }
    return NO;
}

@implementation ContainerTypeObject

+ (id)containerTypeObjectWithClass:(Class)classObj {
    ContainerTypeObject *o = [[self alloc] initWithClass:classObj];
    return o;
}

+ (id)arrayContainerTypeObjectWithValueClass:(Class)valueClass {
    ContainerTypeObject *o = [[self alloc] initWithClass:[NSArray class]];
    ContainerTypeObject *value = [[self alloc] initWithClass:valueClass];
    o.valueClassObj = value;
    return o;
}

+ (id)dictionaryContainerTypeObjectWithValueClass:(Class)valueClass {
    ContainerTypeObject *o = [[self alloc] initWithClass:[NSDictionary class]];
    ContainerTypeObject *value = [[self alloc] initWithClass:valueClass];
    o.valueClassObj = value;
    return o;
}

+ (id)dictionaryContainerTypeObjectWithKeyToValueClass:(NSDictionary<NSString *, ContainerTypeObject *> *)valueClass {
    ContainerTypeObject *o = [[self alloc] initWithClass:[NSDictionary class]];
    o.keyToClass = valueClass;
    return o;
}

- (id)initWithClass:(Class)classObj {
    self = [super init];
    if (self) {
        _classObj = classObj;
    }
    return self;
}

@end

@interface CCClass ()

@property (nonatomic, readwrite) CCClass *superClass;
@property (nonatomic, readwrite) NSDictionary<NSString *, CCProperty *> *properties;
@property (nonatomic, readwrite) NSSet<NSString *> *propertyNameBlackList;
@property (nonatomic, readwrite) NSSet<NSString *> *propertyNameCalculateHash;

@property (nonatomic, readwrite) NSDictionary<NSString *, NSString *> *propertyNameToJsonKeyMap;
@property (nonatomic, readwrite) NSDictionary<NSString *, ContainerTypeObject *> *propertyNameToContainerTypeObjectMap;

@end

@implementation CCClass

// TODO:MARK 他们也用className作为key么
+ (CCClass *)classWithClassObject:(Class)classObject {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *mutableDictionary = nil;
    static dispatch_semaphore_t semaphore;
    dispatch_once(&onceToken, ^{
        mutableDictionary = [NSMutableDictionary dictionary];
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSString *className = NSStringFromClass(classObject);
    CCClass *classInfo = mutableDictionary[className];
    dispatch_semaphore_signal(semaphore);
    
    if (classInfo) {
        return classInfo;
    } else {
        classInfo = [CCClass classWithRuntime:classObject];
        if (classInfo) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            mutableDictionary[className] = classInfo;
            dispatch_semaphore_signal(semaphore);
        }
        return classInfo;
    }
}

+ (BOOL)isSystemClass:(Class)classObject {
    static NSSet *systemClassSets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemClassSets = [NSSet setWithObjects:
                           [NSString class],
                           [NSMutableString class],
                           [NSNumber class],
                           [NSDecimalNumber class],
                           [NSData class],
                           [NSURL class],
                           [NSDate class],
                           [NSArray class],
                           [NSMutableArray class],
                           [NSDictionary class],
                           [NSMutableDictionary class],
                           nil];
    });
    return [systemClassSets containsObject:classObject];
}

+ (CCClass *)classWithRuntime:(Class)classObject {
    if ([self isSystemClass:classObject]) {
        return nil;
    }
    CCClass *c = [[CCClass alloc] init];
    Class superClass = class_getSuperclass(classObject);
    if (superClass != [NSObject class]) {
        c.superClass = [CCClass classWithClassObject:superClass];
    }
    
    if ([classObject conformsToProtocol:@protocol(CCModel)]) {
        id<CCModel> ccmodel = (id<CCModel>)classObject;
        if ([ccmodel respondsToSelector:@selector(propertyNameToJsonKeyMap)]) {
            c.propertyNameToJsonKeyMap = [ccmodel propertyNameToJsonKeyMap];
        }
        if ([ccmodel respondsToSelector:@selector(propertyNameToContainerTypeObjectMap)]) {
            c.propertyNameToContainerTypeObjectMap = [ccmodel propertyNameToContainerTypeObjectMap];
        }
        if ([ccmodel respondsToSelector:@selector(propertyNameBlackList)]) {
            c.propertyNameBlackList = [ccmodel propertyNameBlackList];
        }
        if ([ccmodel respondsToSelector:@selector(propertyNameCalculateHash)]) {
            c.propertyNameCalculateHash = [ccmodel propertyNameCalculateHash];
        }
    }
#ifdef DEBUG
    else {
        if ([classObject respondsToSelector:@selector(propertyNameToJsonKeyMap)]) {
            NSLog(@"You may forget to conform to CCModel in class:%@", classObject);
        } else if ([classObject respondsToSelector:@selector(propertyNameToContainerTypeObjectMap)]) {
            NSLog(@"You may forget to conform to CCModel in class:%@", classObject);
        } else if ([classObject respondsToSelector:@selector(propertyNameBlackList)]) {
            NSLog(@"You may forget to conform to CCModel in class:%@", classObject);
        } else if ([classObject respondsToSelector:@selector(propertyNameCalculateHash)]) {
            NSLog(@"You may forget to conform to CCModel in class:%@", classObject);
        }
    }
#endif
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    Class currentClass = classObject;
    while (currentClass && currentClass != [NSObject class]) {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyCount);
        if (propertyList) {
            for (unsigned int i = 0; i < propertyCount; ++i) {
                objc_property_t property = *(propertyList + i);
                CCProperty *propertyObj = [CCProperty propertyWithRuntime:property];
                NSString *jsonKey = c.propertyNameToJsonKeyMap[propertyObj.propertyName];
                if (jsonKey) {
                    propertyObj.jsonKey = jsonKey;
                } else {
                    propertyObj.jsonKey = propertyObj.propertyName;
                }
                mutableDictionary[propertyObj.jsonKey] = propertyObj;
            }
            free(propertyList);
        }
        currentClass = class_getSuperclass(currentClass);
    }
    c.properties = [mutableDictionary copy];
    
    return c;
}

@end


@interface CCProperty ()

@end

@implementation CCProperty

+ (CCProperty *)propertyWithRuntime:(objc_property_t)objc_property {
    CCProperty *property = [[CCProperty alloc] init];
    const char *propertyName = property_getName(objc_property);
    property.propertyName = [NSString stringWithUTF8String:propertyName];
    
    unsigned int attributeCount = 0;
    objc_property_attribute_t *attributeList = property_copyAttributeList(objc_property, &attributeCount);
    for (unsigned int j = 0; j < attributeCount; ++j) {
        objc_property_attribute_t attribute = *(attributeList + j);
        NSString *attributeName = [NSString stringWithUTF8String:attribute.name];
        if ([attributeName isEqualToString:@"T"]) {
            CCEncodingType encodingType = CCEncodingTypeFromChar(attribute.value);
            property.encodingType = encodingType;
            if (encodingType == CCEncodingTypeObject) {
                NSString *typeName = [NSString stringWithUTF8String:attribute.value];
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@\""];
                NSString *objectType = [typeName stringByTrimmingCharactersInSet:set];
                Class propertyClass = NSClassFromString(objectType);
                if (propertyClass) {
                    property.propertyClass = propertyClass;
                }
                property.objectType = CCObjectTypeFromClass(propertyClass);
            }
        } else if ([attributeName isEqualToString:@"R"]) {
            // readonly
            property.encodingType |= CCEncodingTypePropertyReadonly;
        } else if ([attributeName isEqualToString:@"C"]) {
            // copy
            property.encodingType |= CCEncodingTypePropertyCopy;
        } else if ([attributeName isEqualToString:@"&"]) {
            // retain
            property.encodingType |= CCEncodingTypePropertyRetain;
        } else if ([attributeName isEqualToString:@"N"]) {
            // nonatomic
            property.encodingType |= CCEncodingTypePropertyNonatomic;
        } else if ([attributeName isEqualToString:@"G"]) {
            // custom getter
            property.encodingType |= CCEncodingTypePropertyCustomGetter;
            NSString *value = [NSString stringWithUTF8String:attribute.value];
            property.getter = NSSelectorFromString(value);
        } else if ([attributeName isEqualToString:@"S"]) {
            // custom setter
            property.encodingType |= CCEncodingTypePropertyCustomSetter;
            NSString *value = [NSString stringWithUTF8String:attribute.value];
            property.setter = NSSelectorFromString(value);
        } else if ([attributeName isEqualToString:@"D"]) {
            // dynamic
            property.encodingType |= CCEncodingTypePropertyDynamic;
        } else if ([attributeName isEqualToString:@"W"]) {
            // weak
            property.encodingType |= CCEncodingTypePropertyWeak;
        }
    }
    if (attributeList) {
        free(attributeList);
    }
    
    if (!property.getter && [property.propertyName length] > 0) {
        property.getter = NSSelectorFromString(property.propertyName);
    }
    
    if (!property.setter &&
        [property.propertyName length] > 0 &&
        (property.encodingType & CCEncodingTypePropertyReadonly) != CCEncodingTypePropertyReadonly) {
        NSString *first = [[property.propertyName substringToIndex:1] uppercaseString];
        NSString *left = [property.propertyName substringFromIndex:1];
        NSString *setterName = [NSString stringWithFormat:@"set%@%@:", first, left];
        property.setter = NSSelectorFromString(setterName);
    }
    
    return property;
}

@end
