# Keynote Progress Bar

This AppleScript program adds a customizable progress bar to presentations created with Apple Keynote. The progress bar is configured using commands placed in the presenter notes of your slides. This project utilizes a custom Objective-C framework, `KeynoteProgressBarHelper`, for generating vector graphics (PDF) images of the progress bar.

## Features

- Customizable progress bar with various styling options
- Support for chapters with different styles
- Easy configuration through presenter notes
- Automatic insertion of progress bar images into Keynote slides

## Installation

1. Clone this repository.
2. Open the `KeynoteProgressBarHelper` framework and build it using Xcode.
3. Place the compiled framework in `/Users/your-username/Library/Frameworks`.
4. Run the AppleScript to add progress bars to your Keynote presentation.

## Configuration

To configure the progress bar, add commands to the presenter notes of your Keynote slides. The syntax for the commands is as follows:

### Basic Syntax

```plaintext
{progress bar; command; parameter1=value1; parameter2=value2; ...}
```

### Commands

- `start`: Marks the beginning of the slides where the progress bar should be displayed.
- `stop`: Marks the end of the slides where the progress bar should be displayed.
- `skip`: Skips the progress bar for the current slide.
- `duration`: Sets the duration (in minutes) for the current slide.

### Parameters

- `RemoveAll`: (true/false) Removes all progress bars before starting.
- `ChapterSeparation`: (number) Distance between chapter markers in points.
- `FontFamily`: (string) Font family for the progress bar text.
- `FlipUpsideDown`: (true/false) Flips the progress bar upside down.
- `FontFamilyHighlightedChapter`: (string) Font family for the highlighted chapter text.
- `SetAllPositionsEqual`: (true/false) Sets all progress bar positions to be equal.
- `NumberOfDots`: (number) Number of dots in the progress bar.
- `DotSize`: (number) Size of the dots in points.
- `ContourWidth`: (number) Width of the contour line around the dots.
- `FontSize`: (number) Font size of the progress bar text.
- `chapter`: (string) Name of the current chapter.
- `CompletedDotFillColor`: (array) Color of completed dots in RGBA format (e.g., `{91,96,95,100}`).
- `UncompletedDotFillColor`: (array) Color of uncompleted dots in RGBA format.
- `CompletedDotStrokeColor`: (array) Stroke color of completed dots in RGBA format.
- `UncompletedDotStrokeColor`: (array) Stroke color of uncompleted dots in RGBA format.
- `BaselineOffset`: (number) Baseline offset for the text.
- `Margins`: (array) Margins around the progress bar in the format `{top,right,bottom,left}`.
- `OverwriteAllImages`: (true/false) Overwrites all existing progress bar images.

### Examples

#### Starting Slide

```plaintext
{progress bar; start; RemoveAll=false; ChapterSeparation=90; FontFamily=Helvetica-Light; FlipUpsideDown=false; FontFamilyHighlightedChapter=Helvetica; SetAllPositionsEqual=true; NumberOfDots=43; DotSize=7; ContourWidth=0.2; FontSize=18; chapter=Introduction; CompletedDotFillColor={91,96,95,100}; UncompletedDotFillColor={91,96,95,30}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; BaselineOffset=0; Margins={0,40,0,40}; OverwriteAllImages=true; skip; duration=1.73}
```

#### Intermediate Slide

```plaintext
{progress bar; duration=1.5}
```

#### Ending Slide

```plaintext
{progress bar; skip; stop}
```

## Usage

1. Open your Keynote presentation.
2. Add the configuration commands to the presenter notes of the relevant slides.
3. Run the AppleScript to process the slides and insert the progress bar images.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
