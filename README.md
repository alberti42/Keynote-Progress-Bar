# Keynote Progress Bar<a id="Keynote-Progress-Bar"></a>

This AppleScript program adds a customizable progress bar to presentations created with Apple Keynote. The progress bar is configured using commands placed in the presenter notes of your slides. This project utilizes a custom Objective-C framework, `KeynoteProgressBarHelper`, for generating vector graphics (PDF) images of the progress bar.

![Example Keynote Progress Bar](Docs/Examples/Example-Keynote-Progress-Bar.png)

Download the Keynote presentation [example](https://github.com/alberti42/Keynote-Progress-Bar/raw/main/Docs/Examples/Example-Keynote-Progress-Bar.key), where the _Keynote Progress Bar_ has already been embedded. You only need Keynote to open the presentation and evaluate how the _Keynote Progress Bar_ looks. No other installation is required for a first look. Alternatively, you can download the [PDF](https://github.com/alberti42/Keynote-Progress-Bar/raw/main/Docs/Examples/Example-Keynote-Progress-Bar.pdf) export of the Keynote presentation.

## 1. Table of Contents<a id="toc"></a>

- [Keynote Progress Bar](#Keynote-Progress-Bar)
	- [1. Table of Contents](#toc)
	- [2. Features](#features)
	- [3. Installation](#installation)
	- [4. Usage](#usage)
		- [4.1. Adding progress bar to your presentation](#usage-generation)
		- [4.2. Commands and parameters](#usage-commands)
		- [4.3. Progress bar calculation](#usage-calculation)
  		- [4.4. Adjusting position and size](#usage-positioning)
    		- [4.4.1. Manual adjustment](#usage-positioning-manual)
      		- [4.4.2. Automatic adjustment](#usage-positioning-automatic)
		- [4.5. Example workflow](#usage-examples)
		- [4.6. Running the Script](#usage-running)
	- [#5. Configuration](#configuration)
		- [5.1. Basic syntax of commands](#configuration-syntax)
			- [5.1.1. Commands on the initial slide](#configuration-syntax-initial)
			- [5.1.2. Commands on individual slides](#configuration-syntax-individuals)
		- [5.2. Detailed options](#configuration-detailed)
			- [5.2.1. PreserveExistingImages](#preserve-existing-images)
			- [5.2.2. SetAllPositionsEqual](#set-all-positions-equal)
			- [5.2.3. SameAsPrevious](#same-as-previous)
			- [5.3. RemoveAll](#remove-all)
	- [6. Donations](#donations)
	- [7. Author](#author)
	- [8. Contributing](#contributing)
	- [9. License](#license)

## 2. Features<a id="features"></a>

- Customizable progress bar with various styling options
- Support for chapters with different styles
- Easy configuration through presenter notes
- Automatic insertion of progress bar images into Keynote slides
- Progress bar based on actual presentation time, ensuring accurate visual representation.

## 3. Installation<a id="installation"></a>

1. Clone this repository:
   ```sh
   git clone https://github.com/alberti42/Keynote-Progress-Bar.git
   ```
2. Open the `KeynoteProgressBarHelper` framework in Xcode and build it.
3. Place the compiled framework in `/Users/your-username/Library/Frameworks`.
4. Open the AppleScript `path/to/the/cloned/repository/AppleScript/Add Progress Bar to Keynote.applescript.applescript` with Apple’s _Script Editor_ and save the script in your favorite script location (e.g., `/Users/your-username/Library/Scripts`) as compiled-script format `.scpt`. 
5. Open your Keynote presentation.
6. Add the configuration commands to the presenter notes of the relevant slides. Check section on [usage](#usage) for more information.
7. From the _Script Editor_, run the AppleScript to process the slides and insert the progress bar images to your slides. If you have multiple Keynote presentations opened, only the frontmost document will be considered.

## 4. Usage<a id="usage"></a>

### 4.1. Adding progress bar to your presentation<a id="usage-generation"></a>

1. **Open Your Keynote Presentation:**
   Ensure your Keynote presentation is open before running the script.

2. **Add Configuration Commands:**
   Insert the configuration commands in the presenter notes of your slides. Refer to the examples provided in the `Examples` section for proper syntax and usage.

3. **Run the AppleScript:**
   Open the AppleScript with Apple’s _Script Editor_ and run it. If you have multiple Keynote presentations open, the foremost document will be processed.

### 4.2. Commands and parameters<a id="usage-commands"></a>

To configure the _Keynote Progress Bar_, add commands to the _Presenter Notes_ of your Keynote slides. The syntax for the commands is as follows:

```plaintext
{progress bar; command1; command2=<argument>; command3=<argument>; ...}
```

A detailed description of the commands is provided in [this section](#configuration).

### 4.3. Progress bar calculation<a id="usage-calculation"></a>

The progress of the dots in the _Keynote Progress Bar_ is computed based on the actual time spent on each slide, as indicated by the `duration` field, rather than the slide number. This approach ensures accurate representation of the presentation's progress, especially in cases where a sequence of slides is used to create an animation that conceptually belongs to a single slide. By relying on the `duration` field, the progress bar accurately reflects the time allocated to each section of the presentation, providing a better visual cue for the audience.

## 4.4. Adjusting position and size<a id="usage-positioning"></a>

### 4.4.1. Manual adjustment<a id="usage-positioning-manual"></a>

After running the script for the first time, you may need to adjust the position and size of the _Keynote Progress Bar_ to better fit your slide layout. In fact, the first run of the app, if no previous progress bar existed, places the progress bar at the bottom to fill nearly the entire width. This is seldom ideal. The user is free to change the position by moving the progress bar and resizing it. It is important to uncheck `Constrain proportions` under the panel `Format > Arrange` of Keynote when selecting the progress bar generated in its default position. This allows the user to stretch the progress bar to the desired size. It must be mentioned that in doing so, the aspect ratio may look weird and not properly scaled. The user should not worry. The next execution of the app will use the right size, but also respect the correct aspect ratio for the dots and text. 

1. **Select the Progress Bar:**
   Click on the progress bar in your Keynote slide to select it.

2. **Uncheck Constrain Proportions:**
   In the Keynote menu, go to `Format > Arrange` and uncheck `Constrain proportions` to freely adjust the width and height of the progress bar.

3. **Resize and Position:**
   Drag the progress bar to the desired position and resize it as needed. Don’t worry about the aspect ratio; the next execution of the script will maintain the correct aspect ratio for the dots and text while respecting your adjustments.

### 4.4.2. Automatic adjustment<a id="usage-positioning-automatic"></a>

To automatize the formatting on all slides at once, position and resize the first occurrence of the progress bar image and subsequently run the app with `PreserveExistingImages` set to false (default behavior) and `SetAllPositionsEqual` set to true.

### 4.5. Example workflow<a id="usage-examples"></a>

1. **Initial Setup:**
   On the first slide where you want the progress bar to start, add the following in the presenter notes:
   ```plaintext
   {progress bar; start; RemoveAll=false; ChapterSeparation=90; FontFamily=Helvetica-Light; FlipUpsideDown=false; FontFamilyHighlightedChapter=Helvetica; NumberOfDots=40; DotSize=7; ContourWidth=0.2; FontSize=18; chapter=Introduction; CompletedDotFillColor={91,96,95,100}; UncompletedDotFillColor={91,96,95,30}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; BaselineOffset=0; Margins={0,40,0,40}; SameAsPreviousAutomatic=true; SetAllPositionsEqual=true; PreserveExistingImages=false; skipDrawing; duration=1.5}
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

4. **Handling Slides with Dark Background:** <a id="example-dark"></a>
   For slides with a dark background, customize the colors for better visibility:
   ```plaintext
   {progress bar; duration=1.5; CompletedDotFillColor={255,255,255,100}; UncompletedDotFillColor={255,255,255,60}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; CompletedTextColor={255,255,255,100}; UncompletedTextColor={255,255,255,100};}
   ```

### 4.7. Running the script<a id="usage-running"></a>

1. **Open the Script Editor:**
   Launch Apple’s _Script Editor_ and open the saved AppleScript file.

2. **Run the Script:**
   Click the "Run" button in the _Script Editor_ to execute the script. Ensure that the Keynote presentation you wish to modify is the foremost document.

3. **Verify the Progress Bar:**
   Check your Keynote slides to verify that the progress bar has been added and configured according to your specifications.
   
## 5. Configuration<a id="configuration"></a>

### 5.1. Commands<a id="configuration-syntax"></a>

There are two categories of commands:

1. commands applying to the initial slides. These are typically global configurations.
2. commands applying to the individual slides to customize their particular behavior.

#### 5.1.1. Commands on the initial slide<a id="configuration-syntax-initial"></a>

These commands are used in the `{progress bar; start; ...}` configuration on the first slide, where the progress bar is intended to start, to set up the overall behavior and style of the progress bar throughout the presentation:

**General Commands:**
- `start`: (no argument) Special command marking the slide where the progress bar should be first displayed. It is mandatory to have one slide with this command.
- `RemoveAll`: (true/false; default=false) Special command to clean the presentation from all progress bars; no new progress bars will be generated. Check [this section](#remove-all) for more details.
- `PreserveExistingImages`: (true/false; default=false) Preserves all existing progress bar images. Check [this section](#preserve-existing-images) for more details.

**Chapter Labels:**
- `ChapterSeparation`: (number) Distance between chapter markers in pixels.
- `FontFamily`: (string; default=Helvetica-Light) Font family for the progress bar labels.
- `FontFamilyHighlightedChapter`: (string; default=Helvetica) Font family for the highlighted chapter text.
- `FontSize`: (number; default=12) Font size of the progress bar labels.
- `BaselineOffset`: (number; default=0) Baseline offset for the labels.
- `CompletedTextColor`: (array; default={0, 0, 0, 100}) Color of labels for finished and current chapters in RGBA format.
- `UncompletedTextColor`: (array; default={0, 0, 0, 30}) Color of labels for next chapters in RGBA format.

**Dots:**
- `NumberOfDots`: (integer number; default=40) Number of dots in the progress bar.
- `DotSize`: (floating number; default=7) Size of the dots in pixels.
- `ContourWidth`: (number; default=0.2) Width of the contour line around the dots.
- `CompletedDotFillColor`: (array; default={91, 96, 95, 100}) Color of completed dots in RGBA format (e.g., `{91,96,95,100}`).
- `UncompletedDotFillColor`: (array; default={91, 96, 95, 30}) Color of uncompleted dots in RGBA format.
- `CompletedDotStrokeColor`: (array; default={0, 0, 0, 100}) Stroke color of completed dots in RGBA format.
- `UncompletedDotStrokeColor`: (array; default={0, 0, 0, 100}) Stroke color of uncompleted dots in RGBA format.

**Positioning:**
- `ChapterLabelsAtBottom`: (true/false; default=false) Shows the chapter labels below the dots.
- `SetAllPositionsEqual`: (true/false; default=false) Sets all progress bar positions to be equal. Check [this section](#set-all-positions-equal) for more details.
- `Margins`: (array of numbers; default={0, 0, 0, 0}) Margins around the progress bar in the format `{top,right,bottom,left}`.
- `SameAsPreviousAutomatic`: (true/false; default=false) Applies the command SaveAsPrevious automatically on each slide subsequent to a _Magic Move_ transition. Check [this section](#same-as-previous) for more details.


#### 5.1.2. Commands on individual slides<a id="configuration-syntax-individuals"></a>

These commands are applied to individual slides to control their specific behavior and appearance in the context of the progress bar:

- `duration`: (floating-point number; default=1) Sets the duration in minutes for the current slide.
- `chapter`: (string; default="") Name of the new chapter in your presentation. You can use double quotation marks if the chapter name contains spaces.
- `skipDrawing`: (no argument) Skips drawing the progress bar for the current slide. This command is convenient to hide the progress bar on slides where it would overlap on some graphical elements.
- `SameAsPrevious`: (no argument) Uses the progress bar image from the previous slide to avoid flickering during _Magic Move_ transitions. Check [this section](#same-as-previous) for more details.
- `stop`: (no argument) Special command marking the last slide where the progress bar should be displayed. All slides after the `stop` command will be ignored. It is mandatory to have one slide with this command.

#### 5.1.3. Commands on individual slides overwriting global configurations<a id="configuration-syntax-overwrite"></a>

The following commands can be provided on individual slides to override the global configurations set on the initial slide. These commands allow for customized behavior and appearance of the progress bar on specific slides:

- `CompletedDotFillColor`
- `UncompletedDotFillColor`
- `CompletedDotStrokeColor`
- `UncompletedDotStrokeColor`
- `CompletedTextColor`
- `UncompletedTextColor`
- `BackgroundColor`

Overwriting the global behavior is useful for example when showing the progress bar on a slide with dark background; see [this example](#example-dark).

### 5.2. Detailed description of selected commands<a id="configuration-detailed"></a>

#### 5.2.1. PreserveExistingImages<a id="preserve-existing-images"></a>

When this option is true, the app uses any previously placed progress bar as a reference and updates it, maintaining its size, position, and z-order on the slide. This is particularly useful when the progress bar needs to be positioned as the background element, hidden by other elements in the foreground. By preserving the existing progress bar, the newly generated progress bar images replace the old ones without altering their predefined z-order, ensuring that the intended layering of slide elements is maintained. The default behavior is false.

#### 5.2.2. SetAllPositionsEqual<a id="set-all-positions-equal"></a>

When this option is true, all progress bar images in all slides have the same size and position as the first progress bar. The first progress bar is the first one appearing. If the first slides use the command `skipDrawing`, then it will be the first progress bar on the first slide not containing `skipDrawing`.

#### 5.2.3. SameAsPrevious<a id="same-as-previous"></a>

When this command is used, the current slide reuses the progress bar image generated for the previous slide. This is particularly important when using the _Magic Move_ animation from the previous slide to the current one. By displaying the previous progress bar image, we avoid flickering that would otherwise occur due to the _Magic Move_ animation. However, while the duration for the slide is correctly computed, the progress bar's advancement cannot be displayed when reusing the image from the previous slide.

#### 5.3. RemoveAll<a id="remove-all"></a>

This is a special command in the first slide. When this is true, all images of the progress bar are removed from all slides. This is important when we would like to clean the slides from the progress bar. No progress bar is created.

## 6. Donations<a id="donations"></a>
I would be grateful for any donation to support the development of this plugin.

[<img src="Docs/Images/buy_me_coffee.png" width=300 alt="Buy Me a Coffee QR Code"/>](https://buymeacoffee.com/alberti)

## 7. Author<a id="author"></a>
- **Author:** Andrea Alberti [LinkedIn](https://www.linkedin.com/in/dr-andrea-alberti/) [ORCID](https://orcid.org/0000-0002-1698-3895)
- **ORCID:** <img decoding="async" width="16" height="16" style="width: 16px;" src="https://i0.wp.com/info.orcid.org/wp-content/uploads/2020/12/orcid_16x16.gif?resize=16%2C16&amp;ssl=1" alt="orcid logo 16px" data-recalc-dims="1"> [0000-0002-1698-3895](https://orcid.org/0000-0002-1698-3895)
- **LinkedIn:** [https://www.linkedin.com/in/dr-andrea-alberti/](https://www.linkedin.com/in/dr-andrea-alberti/)
- **GitHub:** [alberti42](https://github.com/alberti42)
- **Donations:** [![Buy Me a Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20a%20Coffee-orange)](https://buymeacoffee.com/alberti)

## 8. Contributing<a id="contributing"></a>

Feel free to contribute to the development of this plugin or report any issues in the [GitHub repository](https://github.com/alberti42/Keynote-Progress-Bar/issues).

## 9. License<a id="license"></a>

This project is licensed under a [custom license](LICENSE).
