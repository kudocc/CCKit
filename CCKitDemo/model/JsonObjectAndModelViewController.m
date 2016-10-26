//
//  JsonObjectAndModelViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "JsonObjectAndModelViewController.h"
#import "NSObject+CCModel.h"
#import "People.h"
#import "Student.h"
#import "Teacher.h"
#import "School.h"

@interface ScalarNumberModel : NSObject <NSCopying>
@property char charTest;
@property unsigned char ucharTest;
@property int intTest;
@property unsigned int uintTest;
@property short shortTest;
@property unsigned short ushortTest;
@property long longTest;
@property unsigned long ulongTest;
@property long long llongTest;
@property unsigned long long ullongTest;
@property float floatTest;
@property double doubleTest;
@property bool cboolTest;
@property BOOL ocboolTest;
@end
@implementation ScalarNumberModel
- (id)copyWithZone:(NSZone *)zone {
    return [self ccmodel_copyWithZone:zone];
}
@end

@interface KeypathPropertyModel : NSObject <CCModel>
@property (nonatomic) NSString *name;
@property (nonatomic) int age;
@end

@implementation KeypathPropertyModel

+ (NSDictionary *)propertyNameToJsonKeyMap {
    return @{@"name":@"cname",
             @"age":@"object.age"};
}

@end

@implementation JsonObjectAndModelViewController

- (void)testScalarNumberModel {
    NSString *jsonString =
    @"{\
        \"charTest\":1,\
        \"ucharTest\":2,\
        \"intTest\":3,\
        \"uintTest\":4,\
        \"shortTest\":5,\
        \"ushortTest\":6,\
        \"longTest\":7,\
        \"ulongTest\":8,\
        \"llongTest\":9,\
        \"ullongTest\":10,\
        \"floatTest\":\"122.222\",\
        \"doubleTest\":1333.333,\
        \"cboolTest\":\"true\",\
        \"ocboolTest\":\"YES\"\
    }";
    
    id model = [ScalarNumberModel ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleObjectModel {
    NSString *jsonString = @"{\"name\":\"kudo\", \"age\":17, \"g\":3}";
    id model = [Student ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleArray {
    NSString *jsonString = @"[1, 2, 3, 4, 5]";
    ContainerTypeObject *container = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSArray *array = [NSArray ccmodel_modelArrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccmodel_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArray {
    // nested array
    NSString *jsonString = @"[[1, 2, 3], [4, 5, 6]]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSNumber class]];
    NSArray *array = [NSArray ccmodel_modelArrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccmodel_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, arrayModel:%@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArrayWithModel {
    // nested array with Model
    NSString *jsonString =
    @"[\
        [\
            {\"name\":\"kudo\", \"age\":17, \"g\":3},\
            {\"name\":\"lan\", \"age\":17, \"g\":3}\
        ],\
        [\
            {\"name\":\"conan\", \"age\":7, \"g\":1},\
            {\"name\":0, \"age\":7, \"g\":1}\
        ]\
    ]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Student class]];
    NSArray *array = [NSArray ccmodel_modelArrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
}

- (void)testSimpleDictionary {
    // simple dictionary
    NSString *jsonString = @"{\"name\":\"KudoCC\", \"count\":2}";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSDictionary *dictionary = [NSDictionary ccmodel_modelDictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccmodel_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testNestedDictionary {
    NSString *jsonString =
    @"{\
        \"name\":\"KudoCC\",\
        \"habbit\":\
            {\
                \"count\":10,\
                \"value\":\
                    [\"basketball\",\"reading\", \"football\"]\
            }\
    }";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForHabbit = [ContainerTypeObject containerTypeObjectWithClass:[NSDictionary class]];
    ContainerTypeObject *objectForHabbitCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    ContainerTypeObject *objectForHabbitValue = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSString class]];
    objectForHabbit.keyToClass = @{@"count":objectForHabbitCount, @"value":objectForHabbitValue};
    NSDictionary *dictionary = [NSDictionary ccmodel_modelDictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccmodel_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testPeople {
    NSString *jsonString =
    @"{\
    \"schoolId\":1024,\
    \"people\":\
        {\
            \"student\":\
                {\
                    \"count\":1112,\
                    \"value\":\
                        [\
                            {\"name\":\"kudo\", \"age\":17, \"g\":3},\
                            {\"name\":\"lan\", \"age\":17, \"g\":3}\
                        ]\
                },\
            \"teacher\":\
                {\
                    \"count\":2, \
                    \"value\":\
                        [\
                            {\"name\":\"zhidi\", \"age\":27, \"subject\":4},\
                            {\"name\":\"maoli\", \"age\":28, \"subject\":5}\
                        ]\
                }\
        },\
    \"homePageURL\":\"http://www.jojojojojo.com\"\
    }";
    id model = [School ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testNSCopying_NSCoding {
    NSString *jsonString =
    @"{\
    \"schoolId\":1024,\
    \"people\":\
        {\
            \"student\":\
                {\
                    \"count\":2,\
                    \"value\":\
                        [\
                            {\"name\":\"kudo\", \"age\":17, \"g\":3},\
                            {\"name\":\"lan\", \"age\":17, \"g\":3}\
                        ]\
                },\
            \"teacher\":\
                {\
                    \"count\":2, \
                    \"value\":\
                        [{\"name\":\"zhidi\", \"age\":27, \"subject\":4}]\
                }\
        },\
    \"homePageURL\":\"http://www.jojojojojo.com\"\
    }";
    id model = [School ccmodel_modelWithJSON:jsonString];
    
    // NSCopying
    {
        id modelCopy = [model copy];
        NSAssert([model isEqual:modelCopy], @"not equal");
        
        NSString *strModel = [model ccmodel_jsonObjectString];
        NSString *strModelCopy = [modelCopy ccmodel_jsonObjectString];
        NSAssert([strModel isEqualToString:strModelCopy], @"not equal");
        
        NSDictionary *dictModel = [modelCopy ccmodel_jsonObjectDictionary];
        NSLog(@"%@(NSCopying), %@", NSStringFromSelector(_cmd), dictModel);
    }
    
    // NSCoding
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        if (data) {
            id modelUnArchive = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSAssert([model isEqual:modelUnArchive], @"not equal");
            
            NSString *strModel = [model ccmodel_jsonObjectString];
            NSString *strModelUnArchive = [modelUnArchive ccmodel_jsonObjectString];
            NSAssert([strModel isEqualToString:strModelUnArchive], @"not equal");
            
            NSDictionary *dict = [modelUnArchive ccmodel_jsonObjectDictionary];
            NSLog(@"%@(NSCoding), %@", NSStringFromSelector(_cmd), dict);
        }
    }
}

- (void)testNSNull {
    NSString *string = @"{\"cname\":\"kudo\", \"object\":{\"age\":10}}";
    NSString *stringException = @"{\"cname\":\"kudo\", \"object\":null}";
    KeypathPropertyModel *model1 = [KeypathPropertyModel ccmodel_modelWithJSON:string];
    KeypathPropertyModel *model2 = [KeypathPropertyModel ccmodel_modelWithJSON:stringException];
    NSString *str1 = [model1 ccmodel_jsonObjectString];
    NSString *str2 = [model2 ccmodel_jsonObjectString];
    NSLog(@"%@", str1);
    NSLog(@"%@", str2);
}

- (void)initView {
    [self testScalarNumberModel];
    
    [self testSimpleObjectModel];
    
    [self testSimpleArray];
    
    [self testNestedArray];
    
    [self testNestedArrayWithModel];
    
    [self testSimpleDictionary];
    
    [self testNestedDictionary];
    
    // test property to json key path
    [self testPeople];
    
    [self testNSCopying_NSCoding];
    
    [self testNSNull];
}

@end
