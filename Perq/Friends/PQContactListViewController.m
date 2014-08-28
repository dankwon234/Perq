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
@property (strong, nonatomic) NSCharacterSet *invalidCharacters;



@end

@implementation PQContactListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addNavigationTitleView];
        self.invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];

        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBlurry.png"]];
    CGRect frame = view.frame;

    CGFloat y = 20.0f;
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(12.0f, y, frame.size.width-24.0f, 36.0f)];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.25f;
    background.layer.cornerRadius = 3.0f;
    background.layer.masksToBounds = YES;
    [view addSubview:background];

    self.phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(12.0f, y, frame.size.width-24.0f, 36.0f)];
    self.phoneNumberField.backgroundColor = [UIColor clearColor];
    self.phoneNumberField.textColor = [UIColor whiteColor];
    self.phoneNumberField.delegate = self;
    self.phoneNumberField.textAlignment = NSTextAlignmentCenter;
    self.phoneNumberField.returnKeyType = UIReturnKeyDone;
    self.phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
    [view addSubview:self.phoneNumberField];
    y += self.phoneNumberField.frame.size.height+12.0f;
    
    UIButton *btnConnect = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConnect.frame = CGRectMake(12.0f, y, frame.size.width-24.0f, 44.0f);
    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnConnect setBackgroundImage:[UIImage imageNamed:@"bgButton.png"] forState:UIControlStateNormal];
    btnConnect.layer.cornerRadius = 4.0f;
    btnConnect.layer.masksToBounds = YES;
    btnConnect.titleLabel.font = [UIFont fontWithName:@"Verdana" size:16.0f];
    [btnConnect addTarget:self action:@selector(scanContacts) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnConnect];
    y += btnConnect.frame.size.height+12.0f;
    
    UILabel *lblExplanation = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, y, frame.size.width-24.0f, 72.0f)];
    lblExplanation.textAlignment = NSTextAlignmentCenter;
    lblExplanation.textColor = [UIColor whiteColor];
    lblExplanation.numberOfLines = 0;
    lblExplanation.text = @"Perc connects you to your friends from your Contact list. We will never share your number with anyone. Promise.";
    lblExplanation.font = [UIFont systemFontOfSize:14.0f];
    [view addSubview:lblExplanation];
    

    
    
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.phoneNumberField becomeFirstResponder];
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

- (void)dismissKeyboard:(UITapGestureRecognizer *)tap
{
    [self.phoneNumberField resignFirstResponder];
}


//search for beginning of first or last name, have search work for only prefixes
- (void)requestAddresBookAccess//call to get address book, latency
{
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        NSLog(@"Address book error");
        [self showAlertWithtTitle:@"Error" message:@""];
        return;
    }
    
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSLog(@"Address book access granted");
                self.session.device.contactList = [NSMutableArray array]; // clear out the old list.
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
//                    bool hasImage = ABPersonHasImageData(contact);
//                    UIImage *image = nil;
//                    if (hasImage==true){
//                        NSData *imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail);
//                        image = [UIImage imageWithData:imageData];
//                    }
                    
                    
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
                NSLog(@"CONTACT LIST: %@", [self.session.device.contactList description]);
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
                            [self.navigationController popViewControllerAnimated:YES];
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

- (void)scanContacts
{
    NSString *phoneNum = self.phoneNumberField.text;
    
    phoneNum = [phoneNum stringByTrimmingCharactersInSet:self.invalidCharacters];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSLog(@"PHONE NUMBER = %@", phoneNum);
    
    
    if (phoneNum.length == 10){
        [self.loadingIndicator startLoading];
        self.session.device.phoneNumber = phoneNum;
        [self performSelector:@selector(requestAddresBookAccess) withObject:nil afterDelay:0.1f];
        return;
    }
    
    [self showAlertWithtTitle:@"Error" message:@"Please enter a valid phone number, like this: 2125559876"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
