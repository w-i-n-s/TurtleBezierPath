//
//  TurtleViewController.m
//  TurtleBezierPath demo
//
//  Created by Nigel Barber on 09/12/2013.
//  Copyright (c) 2013 Nigel Barber. All rights reserved.
//

#import "TurtleViewController.h"

#import "RoundedUISlider.h"

#import "TurtleCanvasView.h"
#import "TurtleDemoPatternView.h"
#import "TurtleBezierPath.h"


@interface TurtleViewController ()

@property( nonatomic, strong ) UISegmentedControl *commandControl;
@property( nonatomic, strong ) UILabel *commandLabel;
@property( nonatomic, strong ) TurtleCanvasView *canvasView;
@property( nonatomic, strong ) TurtleCanvasView *pointerView;

@property( nonatomic, strong ) TurtleBezierPath *path;
@property( nonatomic, strong ) TurtleBezierPath *previewPath;

@property( nonatomic, strong ) RoundedUISlider *valueSlider0;
@property( nonatomic, strong ) RoundedUISlider *valueSlider1;

@end

@implementation TurtleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [ self initDemoApp ];
}

-(void)viewWillAppear:(BOOL)animated
{
    [ super viewWillAppear:animated ];
    
    [ self layoutViews ];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [ self layoutViews ];
}


#pragma mark - Layout

-(void)layoutViews
{
    self.commandLabel.frame = CGRectMake( 0.0f, 20.0f, self.view.bounds.size.width, self.commandLabel.font.pointSize * 1.5f );
    
    self.valueSlider0.frame  = self.valueSlider1.frame = CGRectMake( 0.0, 0.0, self.commandControl.bounds.size.width, self.valueSlider0.bounds.size.height );
    
    CGFloat originY = self.view.bounds.size.height;
    
    for( UIView *view in @[ self.valueSlider1, self.valueSlider0, self.commandControl ])
    {
        view.frame = CGRectMake(( self.view.bounds.size.width - view.bounds.size.width ) / 2.0f, originY - view.bounds.size.height, view.bounds.size.width, view.bounds.size.height );
        
        originY = view.frame.origin.y;
    }
    
    [ self positionPointer ];
}


#pragma mark - Controls

-(void)commmandSelected:(id)sender
{
    [ self selectCommmandAtIndex:self.commandControl.selectedSegmentIndex ];
}

-(void)sliderValueChanged0:(id)sender
{
    [ self updateCommandForIndex:self.commandControl.selectedSegmentIndex ];
}

-(void)sliderValueChanged1:(id)sender
{
   [ self updateCommandForIndex:self.commandControl.selectedSegmentIndex ];
}


#pragma mark - Demo app

-(void)initDemoApp
{
    self.path = [ TurtleBezierPath new ];
    [ self.path home ];
    self.path.lineWidth = 2.0f;
    self.path.lineCapStyle = kCGLineCapRound;
    self.previewPath = [ self.path copy ];
    
    self.canvasView = [[ TurtleCanvasView alloc ] initWithFrame:self.view.bounds ];
    self.canvasView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [ self.view addSubview:self.canvasView ];
    
    self.pointerView = [[ TurtleCanvasView alloc ] initWithFrame:CGRectMake( 0.0f, 0.0f, 40.0f, 40.0f )];
    self.pointerView.backgroundColor = [ UIColor clearColor ];
    self.pointerView.strokeColour = [ UIColor redColor ];
    self.pointerView.path = [ self pointerPath ];
    [ self.view addSubview:self.pointerView ];
    
    
    self.commandLabel = [ UILabel new ];
    self.commandLabel.backgroundColor = [ UIColor clearColor ];
    self.commandLabel.font = [ UIFont fontWithName:@"Menlo-Regular" size:18.0f ];
    self.commandLabel.textAlignment = NSTextAlignmentCenter;
    self.commandLabel.textColor = [ UIColor blackColor ];
    self.commandLabel.text = @"commandLabel";
    [ self.view addSubview:self.commandLabel ];
    
    self.commandControl = [[ UISegmentedControl alloc ] initWithItems:@[ @"forward", @"turn", @"leftArc", @"rightArc", @"up" ]];
    self.commandControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [ self.commandControl addTarget:self action:@selector(commmandSelected:) forControlEvents:UIControlEventValueChanged ];
    [ self.view addSubview:self.commandControl ];
    
    self.valueSlider0 = [ RoundedUISlider new ];
    [ self.valueSlider0 addTarget:self action:@selector(sliderValueChanged0:) forControlEvents:UIControlEventValueChanged ];
    [ self.view addSubview:self.valueSlider0 ];
    
    self.valueSlider1 = [ RoundedUISlider new ];
    [ self.valueSlider1 addTarget:self action:@selector(sliderValueChanged1:) forControlEvents:UIControlEventValueChanged ];
    [ self.view addSubview:self.valueSlider1 ];
    
    [ self selectCommmandAtIndex: -1 ];
}


-(TurtleBezierPath *)pointerPath
{
    TurtleBezierPath *path = [ TurtleBezierPath new ];

    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 2.0;
    
    [ path home ];
    [ path forward:0.01f ];
    
    [ path up ];
    
    [ path home ];
    [ path forward: 20.0f ];
    [ path turn:180.0f ];
    [ path down ];
    [ path leftArc:40.f turn:30.0f ];
    
    [ path up ];
    
    [ path home ];
    [ path forward: 20.0f ];
    [ path turn:180.0f ];
    [ path down ];
    [ path rightArc:40.f turn:30.0f ];
    
    return path;
}

-(void)positionPointer
{
    TurtleBezierPath *centredPath = [ self.previewPath copy ];
    [ centredPath centreInBounds:self.view.bounds ];
    
    self.pointerView.center = centredPath.currentPoint;
    self.pointerView.transform = CGAffineTransformMakeRotation( centredPath.bearing * M_PI / 180.0f );
}

-(void)selectCommmandAtIndex:(NSInteger)index
{
    self.path = self.previewPath;
    
    self.valueSlider0.hidden = !( index >= 0 && index < 4 );
    self.valueSlider1.hidden = !( index > 1 && index < 4 );
    
    self.valueSlider0.value = 0.0f;
    self.valueSlider1.value = ( index > 1 ) ? 90.0f : 0.0f;
    self.valueSlider0.maximumValue = ( index == 1 ) ? 360.0f : 100.0f;
    self.valueSlider1.maximumValue = 360.0f;
    
    self.valueSlider0.rounding = ( index == 1 ) ? 5.0f : 1.0f;
    self.valueSlider1.rounding = 5.0f;
    
    [ self updateCommandForIndex:index ];
}


-(void)updateCommandForIndex:(NSInteger)index
{
    [ self updateCommandLabelForIndex:index ];
    
    if( index < 0 )
    {
        return;
    }
    
    self.previewPath = [ self.path copy ];
    
    if( index == 0 && self.valueSlider0.value > 0.0f )
    {
        [ self.previewPath forward:self.valueSlider0.value ];
    }
    else if( index == 1 && self.valueSlider0.value > 0.0f )
    {
        [ self.previewPath turn:self.valueSlider0.value ];
    }
    else if( index == 2 && self.valueSlider0.value > 0.0f && self.valueSlider1.value > 0.0f )
    {
        [ self.previewPath leftArc:self.valueSlider0.value turn:self.valueSlider1.value ];
    }
    else if( index == 3 && self.valueSlider0.value > 0.0f && self.valueSlider1.value > 0.0f )
    {
        [ self.previewPath rightArc:self.valueSlider0.value turn:self.valueSlider1.value ];
    }
    else if( index == 4 )
    {
        if( self.previewPath.penUp )
        {
            [ self.previewPath down ];
        }
        else
        {
            [ self.previewPath up ];
        }
    }
    self.canvasView.path = self.previewPath;
    
    [ self positionPointer ];
    self.pointerView.alpha = ( self.previewPath.penUp ) ? 0.333f : 1.0f;
    
    NSString *downUp = ( self.previewPath.penUp ) ? @"down" : @"up";
    [ self.commandControl setTitle:downUp forSegmentAtIndex:4 ];
}

-(void)updateCommandLabelForIndex:(NSInteger)index
{
    if( index < 0 )
    {
        self.commandLabel.text = nil;
        return;
    }
    
    NSString *commandTitle = [ self.commandControl titleForSegmentAtIndex:index ];
    
    if( index < 2 )
    {
        self.commandLabel.text = [ NSString stringWithFormat:@"[ path %@:%g ]", commandTitle, self.valueSlider0.value ];
    }
    else if( index < 4 )
    {
        self.commandLabel.text = [ NSString stringWithFormat:@"[ path %@:%g turn:%g ]", commandTitle, self.valueSlider0.value, self.valueSlider1.value ];
    }
    else
    {
        self.commandLabel.text = [ NSString stringWithFormat:@"[ path %@ ]", commandTitle ];
    }
}

@end
