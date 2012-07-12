/* UIContactCell.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU Library General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */  

#import "UIContactCell.h"

#import "FastAddressBook.h"

@implementation UIContactCell

@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize avatarImage;
@synthesize contact;


#pragma mark - Lifecycle Functions

- (id)initWithIdentifier:(NSString*)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) != nil) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"UIContactCell"
                                                              owner:self
                                                            options:nil];
    
        if ([arrayOfViews count] >= 1) {
            [self addSubview:[[arrayOfViews objectAtIndex:0] retain]];
        }
    }
    return self;
}

- (void) dealloc {
    [firstNameLabel release];
    [lastNameLabel release];
    [avatarImage release];
    
    [super dealloc];
}


#pragma mark - Property Functions

- (void)setContact:(ABRecordRef)acontact {
    contact = acontact;
    [self update];
}

#pragma mark - 

- (void)touchUp:(id) sender {
    [self setHighlighted:true animated:true];
}

- (void)touchDown:(id) sender {
    [self setHighlighted:false animated:true];
}

- (void)update {
    CFStringRef lFirstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
    CFStringRef lLocalizedFirstName = (lFirstName != nil)?ABAddressBookCopyLocalizedLabel(lFirstName):nil;
    CFStringRef lLastName = ABRecordCopyValue(contact, kABPersonLastNameProperty);
    CFStringRef lLocalizedLastName = (lFirstName != nil)?ABAddressBookCopyLocalizedLabel(lLastName):nil;
    
    if(lLocalizedFirstName != nil)
        [firstNameLabel setText: (NSString *)lLocalizedFirstName];
    else
        [firstNameLabel setText: @""];
    
    if(lLocalizedLastName != nil)
        [lastNameLabel setText: (NSString *)lLocalizedLastName];
    else
        [lastNameLabel setText: @""];
    
    if(lLocalizedLastName != nil)
        CFRelease(lLocalizedLastName);
    if(lLastName != nil)
        CFRelease(lLastName);
    if(lLocalizedFirstName != nil)
        CFRelease(lLocalizedFirstName);
    if(lFirstName != nil)
        CFRelease(lFirstName);
    
    // Avatar
    UIImage *image = [FastAddressBook getContactImage:contact thumbnail:true];
    if(image == nil) {
        image = [UIImage imageNamed:@"avatar_unknown_small.png"];
    }
    [avatarImage setImage:image];
    
    //
    // Adapt size
    //
    CGRect firstNameFrame = [firstNameLabel frame];
    CGRect lastNameFrame = [lastNameLabel frame];
    
    lastNameFrame.origin.x -= firstNameFrame.size.width;
    
    // Compute firstName size
    CGSize contraints;
    contraints.height = [firstNameLabel frame].size.height;
    contraints.width = ([lastNameLabel frame].size.width + [lastNameLabel frame].origin.x) - [firstNameLabel frame].origin.x;
    CGSize firstNameSize = [[firstNameLabel text] sizeWithFont:[firstNameLabel font] constrainedToSize: contraints];
    firstNameFrame.size.width = firstNameSize.width;
    
    // Compute lastName size & position
    lastNameFrame.origin.x += firstNameFrame.size.width;
    lastNameFrame.size.width = (contraints.width + [firstNameLabel frame].origin.x) - lastNameFrame.origin.x;
    
    [firstNameLabel setFrame: firstNameFrame];
    [lastNameLabel setFrame: lastNameFrame];
}

@end