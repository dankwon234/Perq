//
//  PQContactListViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/21/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQContactListViewController.h"
#import "PQSocialAccountsManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface PQContactListViewController ()
@property (strong, nonatomic) UITextField *phoneNumberField;
@end

@implementation PQContactListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addNavigationTitleView];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor greenColor];
    CGRect frame = view.frame;

    
    self.phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(12.0f, frame.size.height-46.0f, frame.size.width-24.0f, 36.0f)];
    self.phoneNumberField.backgroundColor = [UIColor redColor];
//    self.phoneNumberField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:self.phoneNumberField];
    
    
    
    
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestAddresBookAccess];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}



//search for beginning of first or last name, have search work for only prefixes
- (void)requestAddresBookAccess//call to get address book, latency
{
    [self.loadingIndicator startLoading];
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Address book error");
                //                [self.delegate addressBookHelperError:self];
            }
            else if (granted) {
                NSLog(@"Address book access granted");
                NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
                for( int i=0; i<allContacts.count; i++) {
                    ABRecordRef contact = (__bridge ABRecordRef)allContacts[i];
                    
                    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
                    //                    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
                    
                    // email:
                    //                    ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
                    //                    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
                    
                    // phone:
                    ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
                    NSString *phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
                    
                    
                    // image:
                    bool hasImage = ABPersonHasImageData(contact);
                    UIImage *image = nil;
                    if (hasImage==true){
                        NSData *imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail);
                        image = [UIImage imageWithData:imageData];
                    }
                    
                    
                    BOOL enoughInfo = NO;
                    if (firstName != nil && phoneNumber != nil)
                        enoughInfo = YES;
                    
                    if (enoughInfo){
                        //                        contactInfo[@"firstName"] = firstName;
                        //                        contactInfo[@"phoneNumber"] = phoneNumber;
                        
                        NSString *formattedNumber = @"";
                        static NSString *numbers = @"0123456789";
                        for (int i=0; i<phoneNumber.length; i++) {
                            NSString *character = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
                            if ([numbers rangeOfString:character].location != NSNotFound){
                                formattedNumber = [formattedNumber stringByAppendingString:character];
                                
                                NSString *firstNum = [formattedNumber substringWithRange:NSMakeRange(0, 1)];
                                if ([firstNum isEqualToString:@"1"])
                                    formattedNumber = [formattedNumber substringFromIndex:1];
                            }
                        }
                        
                        //                        contactInfo[@"formattedNumber"] = formattedNumber;
                        
                        //                        if (lastName != nil)
                        //                            contactInfo[@"lastName"] = lastName;
                        //
                        //                        if (email != nil)
                        //                            contactInfo[@"email"] = email;
                        //
                        //                        if (image != nil)
                        //                            contactInfo[@"image"] = image;
                        
                        //                        [self.session.device.contactList addObject:contactInfo];
                        
                        [self.session.device.contactList addObject:formattedNumber];
                    }
                }
                
                
                [self.session.device.contactList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                NSLog(@"%@", [self.session.device.contactList description]);
                [self.session.device cacheDevice];
                
                
                [[PQWebServices sharedInstance] updateDevice:self.session.device completion:^(id result, NSError *error){
                    if (error){
                        NSLog(@"ERROR: %@", [error localizedDescription]);
                    }
                    else{
                        NSLog(@"%@", [result description]);
                        NSDictionary *results = (NSDictionary *)result;
                        NSString *confirmation = results[@"confirmation"];
                        if ([confirmation isEqualToString:@"success"]){
                            NSDictionary *device = results[@"device"];
                            [self.session.device populate:device];
                        }
                        else{
                            [self showAlertWithtTitle:@"Error" message:results[@"error"]];
                        }
                    }
                    
                }];
                
                [self.loadingIndicator stopLoading];
                
                CFRelease(addressBook);
            }
            else {
                NSLog(@"Address book access denied");
                [self showAlertWithtTitle:@"Addres Book Unauthorized" message:@"Please go to the settings app and allow Perc to access your address book to invite members."];
            }
            
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
