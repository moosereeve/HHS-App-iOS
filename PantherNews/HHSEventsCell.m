//
//  HHSEventsCell.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/22/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSEventsCell.h"

@implementation HHSEventsCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}



@end
