//
//  HHSDailyAnnCell.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSDailyAnnCell.h"

@implementation HHSDailyAnnCell

- (void)awakeFromNib
{
    /*NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];*/
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateInterfaceForDynamicTypeSize
{
    //UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //self.titleLabel.font = font;
    //self.dateLabel.font = font;
    //self.detailTextLabel.font = font;
    
    //static NSDictionary *imageSizeDictionary;
    
    /*if (!imageSizeDictionary) {
        imageSizeDictionary = @{ UIContentSizeCategoryExtraSmall: @40,
                                 UIContentSizeCategorySmall: @40,
                                 UIContentSizeCategoryMedium: @40,
                                 UIContentSizeCategoryLarge: @40,
                                 UIContentSizeCategoryExtraLarge: @45,
                                 UIContentSizeCategoryExtraExtraLarge: @55,
                                 UIContentSizeCategoryExtraExtraExtraLarge: @65};
        
    }*/
    //NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    //NSNumber *imageSize = imageSizeDictionary[userSize];
    //self.imageViewHeightConstraint.constant = imageSize.floatValue;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}



@end
