//
//  ContactViewController.m
//  CCKitDemo
//
//  Created by rui yuan on 2017/12/3.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "ContactViewController.h"
#import <Contacts/Contacts.h>

//@interface ContactTableViewCell : UITableViewCell
//@end
//
//@implementation ContactTableViewCell
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//    }
//    return self;
//}
//
//@end

@interface ContactViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) CNContactFormatter *formatter;
@property (nonatomic) NSArray<CNContact *> *contacts;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    [self.view addSubview:self.tableView];
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    formatter.style = CNContactFormatterStyleFullName;
    self.formatter = formatter;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (!granted) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You didn't allow us to access the Contacts, so we can't help you!" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Sorry for that" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        NSMutableArray *contacts = [NSMutableArray array];
        
        NSError *fetchError;
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[ CNContactIdentifierKey, CNContactPhoneNumbersKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey ]];
        
        BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
            NSLog(@"contact identifier : %@, family name:%@, given name:%@, middle name:%@", contact.identifier, contact.familyName, contact.givenName, contact.middleName);
            for (CNLabeledValue *value in contact.phoneNumbers) {
                CNPhoneNumber *phoneNum = value.value;
                if (phoneNum.stringValue.length > 0) {
                    NSLog(@"contact phone label:%@, phone number:%@", value.label, phoneNum.stringValue);
                }
            }
            [contacts addObject:contact];
        }];
        
        if (!success) {
            NSLog(@"fail to requeset contacts");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contacts = [contacts copy];
            
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    CNContact *contact = self.contacts[indexPath.row];
    
    if (contact.thumbnailImageData.length > 0) {
        cell.imageView.image = [UIImage imageWithData:contact.thumbnailImageData];
    } else {
        cell.imageView.image = nil;
    }
    
    NSMutableString *phoneNumber = [[NSMutableString alloc] init];
    
    for (CNLabeledValue *value in contact.phoneNumbers) {
        CNPhoneNumber *phoneNum = value.value;
        [phoneNumber appendString:phoneNum.stringValue];
        [phoneNumber appendString:@" "];
    }
    
    NSString *name = [self.formatter stringFromContact:contact];
    NSString *full = [name stringByAppendingFormat:@" - %@", phoneNumber];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = full;
    return cell;
}

@end
