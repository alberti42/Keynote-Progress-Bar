# Keynote Progress Bar<a id="Keynote-Progress-Bar"></a>

This AppleScript program adds a customizable progress bar to presentations created with Apple Keynote. The progress bar is configured using commands placed in the presenter notes of your slides. This project utilizes a custom Objective-C framework, `KeynoteProgressBarHelper`, for generating vector graphics (PDF) images of the progress bar.

## 1. Table of Contents<a id="toc"></a>

- [Keynote Progress Bar](#Keynote-Progress-Bar)
	- [Table of Contents](#toc)
	- [[#2. Features|2. Features]]
	- [[#3. Installation|3. Installation]]
	- [[#4. Usage|4. Usage]]
		- [[#4.1. Adding progress bar to your presentation|4.1. Adding progress bar to your presentation]]
		- [[#4.2. Commands and parameters|4.2. Commands and parameters]]
		- [[#4.3. Progress bar calculation|4.3. Progress bar calculation]]
		- [[#4.4. Example workflow|4.4. Example workflow]]
		- [[#4.5. Running the Script|4.5. Running the Script]]
		- [[#4.6. Adjusting Position and Size|4.6. Adjusting Position and Size]]
	- [[#5. Configuration|5. Configuration]]
		- [[#5.1. Basic syntax of commands|5.1. Basic syntax of commands]]
			- [[#5.1.1. Commands on the initial slide|5.1.1. Commands on the initial slide]]
			- [[#5.1.2. Commands on individual slides|5.1.2. Commands on individual slides]]
		- [[#5.2. Detailed options|5.2. Detailed options]]
			- [[#5.2.1. PreserveExistingImages|5.2.1. PreserveExistingImages]]
			- [[#5.2.2. SetAllPositionsEqual|5.2.2. SetAllPositionsEqual]]
			- [[#5.2.3. SameAsPrevious|5.2.3. SameAsPrevious]]
			- [[#5.3. RemoveAll|5.3. RemoveAll]]
	- [[#6. Positioning and Resizing|6. Positioning and Resizing]]
	- [[#7. Donations|7. Donations]]
	- [[#8. Author|8. Author]]
	- [[#9. Contributing|9. Contributing]]
	- [[#10. License|10. License]]


## 2. Features

- Customizable progress bar with various styling options
- Support for chapters with different styles
- Easy configuration through presenter notes
- Automatic insertion of progress bar images into Keynote slides
- Progress bar based on actual presentation time, ensuring accurate visual representation.

## 3. Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/alberti42/Keynote-ProgressBar.git
   ```
2. Open the `KeynoteProgressBarHelper` framework in Xcode and build it.
3. Place the compiled framework in `/Users/your-username/Library/Frameworks`.
4. Open the AppleScript `path/to/the/cloned/repository/AppleScript/Add Progress Bar to Keynote.applescript.applescript` with Apple’s _Script Editor_ and save the script in your favorite script location (e.g., `/Users/your-username/Library/Scripts`) as compiled-script format `.scpt`. 
5. Open your Keynote presentation.
6. Add the configuration commands to the presenter notes of the relevant slides. Check section on [[#4. Usage|usage]] for more information.
7. From the _Script Editor_, run the AppleScript to process the slides and insert the progress bar images to your slides. If you have multiple Keynote presentations opened, only the frontmost document will be considered.

## 4. Usage

### 4.1. Adding progress bar to your presentation

1. **Open Your Keynote Presentation:**
   Ensure your Keynote presentation is open before running the script.

2. **Add Configuration Commands:**
   Insert the configuration commands in the presenter notes of your slides. Refer to the examples provided in the `Examples` section for proper syntax and usage.

3. **Run the AppleScript:**
   Open the AppleScript with Apple’s _Script Editor_ and run it. If you have multiple Keynote presentations open, the foremost document will be processed.

### 4.2. Commands and parameters

- **Global Configuration Commands:** These are set on the initial slide using the `{progress bar; start; ...}` command.
  - `start`, `RemoveAll`, `ChapterSeparation`, `FontFamily`, `FontFamilyHighlightedChapter`, `FontSize`, `FlipUpsideDown`, `SetAllPositionsEqual`, `NumberOfDots`, `DotSize`, `ContourWidth`, `CompletedDotFillColor`, `UncompletedDotFillColor`, `CompletedDotStrokeColor`, `UncompletedDotStrokeColor`, `CompletedTextColor`, `UncompletedTextColor`, `BaselineOffset`, `Margins`, `PreserveExistingImages`.

- **Individual Slide Commands:** These are set on each slide to control specific behaviors.
  - `duration`, `chapter`, `skipDrawing`, `stop`.

### 4.3. Progress bar calculation

The progress of the dots in the progress bar is computed based on the actual time spent on each slide, as indicated by the `duration` field, rather than the slide number. This approach ensures accurate representation of the presentation's progress, especially in cases where a sequence of slides is used to create an animation that conceptually belongs to a single slide. By relying on the `duration` field, the progress bar accurately reflects the time allocated to each section of the presentation, providing a better visual cue for the audience.

### 4.4. Example workflow

1. **Initial Setup:**
   On the first slide where you want the progress bar to start, add the following in the presenter notes:
   ```plaintext
   {progress bar; start; duration=2; skipDrawing; ChapterSeparation=90; FontFamily=Helvetica-Light; NumberOfDots=50; DotSize=6; ContourWidth=0.2; FontSize=14; CompletedDotFillColor={0,128,0,100}; UncompletedDotFillColor={128,128,128,50}}
   ```

2. **Intermediate Slides:**
   For each intermediate slide, set the duration:
   ```plaintext
   {progress bar; duration=1.5}
   ```

3. **Ending the Progress Bar:**
   On the final slide where you want the progress bar to end, add:
   ```plaintext
   {progress bar; stop}
   ```

4. **Handling Slides with Dark Background:**
   For slides with a dark background, customize the colors for better visibility:
   ```plaintext
   {progress bar; duration=1.5; CompletedDotFillColor={255,255,255,100}; UncompletedDotFillColor={255,255,255,60}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; CompletedTextColor={255,255,255,100}; UncompletedTextColor={255,255,255,100};}
   ```

### 4.5. Running the Script

1. **Open the Script Editor:**
   Launch Apple’s _Script Editor_ and open the saved AppleScript file.

2. **Run the Script:**
   Click the "Run" button in the _Script Editor_ to execute the script. Ensure that the Keynote presentation you wish to modify is the foremost document.

3. **Verify the Progress Bar:**
   Check your Keynote slides to verify that the progress bar has been added and configured according to your specifications.

### 4.6. Adjusting Position and Size

After running the script for the first time, you may need to adjust the position and size of the progress bar to better fit your slide layout:

1. **Select the Progress Bar:**
   Click on the progress bar in your Keynote slide to select it.

2. **Uncheck Constrain Proportions:**
   In the Keynote menu, go to `Format > Arrange` and uncheck `Constrain proportions` to freely adjust the width and height of the progress bar.

3. **Resize and Position:**
   Drag the progress bar to the desired position and resize it as needed. Don’t worry about the aspect ratio; the next execution of the script will maintain the correct aspect ratio for the dots and text while respecting your adjustments.

By following these steps, you can effectively add and customize a progress bar in your Keynote presentations, providing a clear visual cue of the presentation's progress based on the actual time allocated to each slide.

   
## 5. Configuration

To configure the progress bar, add commands to the presenter notes of your Keynote slides. The syntax for the commands is as follows:

### 5.1. Basic syntax of commands

Commands can be provided by including in the _Presenter Notes_ of Keynote a string with the following format:

```plaintext
{progress bar; command; parameter1=value1; parameter2=value2; ...}
```

There are two categories of commands:

1. commands applying to the initial slides. These are typically global configurations.
2. commands applying to the individual slides to customize their particular behavior.

#### 5.1.1. Commands on the initial slide

These commands are used in the `{progress bar; start; ...}` configuration on the first slide, where the progress bar is intended to start, to set up the overall behavior and style of the progress bar throughout the presentation:

**General Commands:**
- `start`: (no argument) Special command marking the slide where the progress bar should be first displayed.
- `RemoveAll`: (true/false; default=false) Special command to clean the presentation from all progress bars; no new progress bars will be generated.
- `PreserveExistingImages`: (true/false; default=false) Preserves all existing progress bar images. Check the section dedicated to [PreserveExistingImages](#my-anchor) for more details.

**Chapter Labels:**
- `ChapterSeparation`: (number) Distance between chapter markers in pixels.
- `FontFamily`: (string) Font family for the progress bar labels.
- `FontFamilyHighlightedChapter`: (string) Font family for the highlighted chapter text.
- `FontSize`: (number) Font size of the progress bar labels.
- `BaselineOffset`: (number) Baseline offset for the labels.
- `CompletedTextColor`: (array; default={0, 0, 0, 100}) Color of labels for finished and current chapters in RGBA format.
- `UncompletedTextColor`: (array; default={0, 0, 0, 30}) Color of labels for next chapters in RGBA format.

**Dots:**
- `NumberOfDots`: (integer number; default=40) Number of dots in the progress bar.
- `DotSize`: (floating number; default=7) Size of the dots in pixels.
- `ContourWidth`: (number; default=0.2) Width of the contour line around the dots.
- `CompletedDotFillColor`: (array) Color of completed dots in RGBA format (e.g., `{91,96,95,100}`).
- `UncompletedDotFillColor`: (array) Color of uncompleted dots in RGBA format.
- `CompletedDotStrokeColor`: (array) Stroke color of completed dots in RGBA format.
- `UncompletedDotStrokeColor`: (array) Stroke color of uncompleted dots in RGBA format.

**Positioning:**
- `FlipUpsideDown`: (true/false) Flips the progress bar upside down.
- `SetAllPositionsEqual`: (true/false) Sets all progress bar positions to be equal. Check [[#6.2. SetAllPositionsEqual|SetAllPositionsEqual]] for more details.
- `Margins`: (array of numbers) Margins around the progress bar in the format `{top,right,bottom,left}`.


#### 5.1.2. Commands on individual slides

These commands are applied to individual slides to control their specific behavior and appearance in the context of the progress bar:

- `duration`: (floating-point number) Sets the duration in minutes for the current slide.
- `chapter`: (string) Name of the new chapter in your presentation. You can use double quotation marks if the chapter name contains spaces.
- `skipDrawing`: (no argument) Skips drawing the progress bar for the current slide. This command is convenient to hide the progress bar on slides where it would overlap on some graphical elements.
- `stop`: (no argument) Special command marking the last slide where the progress bar should be displayed. All slides after the `stop` command will be ignored.
- `SameAsPrevious`: (no argument) Uses the progress bar image from the previous slide to avoid flickering during _Magic Move_ transitions. Check [[#6.3. SameAsPrevious|SameAsPrevious]] for more details.

### 5.2. Detailed options

#### 5.2.1. PreserveExistingImages<a id="PreserveExistingImages"></a>

When this option is true (default), the app uses any previously placed progress bar as a reference and updates it, maintaining its size, position, and z-order on the slide. This is particularly useful when the progress bar needs to be positioned as the background element, hidden by other elements in the foreground. By preserving the existing progress bar, the newly generated progress bar images replace the old ones without altering their predefined z-order, ensuring that the intended layering of slide elements is maintained.

#### 5.2.2. SetAllPositionsEqual

When this option is true, all progress bar images in all slides have the same size and position as the first progress bar. The first progress bar is the first one appearing. If the first slides use the command `skipDrawing`, then it will be the first progress bar on the first slide not containing `skipDrawing`.

#### 5.2.3. SameAsPrevious

When this command is used, the current slide reuses the progress bar image generated for the previous slide. This is particularly important when using the _Magic Move_ animation from the previous slide to the current one. By displaying the previous progress bar image, we avoid flickering that would otherwise occur due to the _Magic Move_ animation. However, while the duration for the slide is correctly computed, the progress bar's advancement cannot be displayed when reusing the image from the previous slide.

#### 5.3. RemoveAll

This is a special command in the first slide. When this is true, all images of the progress bar are removed from all slides. This is important when we would like to clean the slides from the progress bar. No progress bar is created.

## 6. Positioning and Resizing

The first run of the app, if no previous progress bar existed, places the progress bar at the bottom to fill nearly the entire width. This is seldom ideal. The user is free to change the position by moving the progress bar and resizing it. It is important to uncheck `Constrain proportions` under the panel `Format > Arrange` of Keynote when selecting the progress bar generated in its default position. This allows the user to stretch the progress bar to the desired size. It must be mentioned that in doing so, the aspect ratio may look weird and not properly scaled. The user should not worry. The next execution of the app will use the right size, but also respect the correct aspect ratio for the dots and text.

## 7. Donations
I would be grateful for any donation to support the development of this plugin.

[<img src="docs/images/buy_me_coffee.png" width=300 alt="Buy Me a Coffee QR Code"/>](https://buymeacoffee.com/alberti)

## 8. Author
- **Author:** Andrea Alberti
- **GitHub Profile:** [alberti42](https://github.com/alberti42)
- **Donations:** [![Buy Me a Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20a%20Coffee-orange)](https://buymeacoffee.com/alberti)

Feel free to contribute to the development of this plugin or report any issues in the [GitHub repository](https://github.com/alberti42/import-attachments-plus/issues).

## 9. Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## 10. License

This project is licensed under the MIT License; see the [LICENSE](LICENSE) file for details.
