
# Porcupine Wake Word Engine Demo for STM32F411 (Multiple languages)

This package contains a demo project for the STM32F411 Discovery kit using Porcupine wake word engine. 

## Supported Languages

1. English
2. French
3. German
4. Spanish

## Installation

For this demo, you need to: 
1. Download and install [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html), which is an all-in-one multi-OS development tool for STM32 microcontrollers.
1. Download [STM32Cube middleware for audio PDM to PCM conversion](https://www.st.com/en/licensed-software/audiopdm-mw.html) and copy it to the project folder. A more detailed guide can be found in the [readme](./stm32f411e-disco/Middlewares/ST/STM32_Audio/Addons/PDM/readme.txt) file.

## AccessKey

Porcupine requires a valid `AccessKey` at initialization. `AccessKey`s act as your credentials when using Porcupine SDKs.
You can create your `AccessKey` for free. Make sure to keep your `AccessKey` secret.

To obtain your `AccessKey`:
1. Login or Signup for a free account on the [Picovoice Console](https://picovoice.ai/console/).
2. Once logged in, go to the [`AccessKey` tab](https://console.picovoice.ai/access_key) to create one or use an existing `AccessKey`.

## Usage

In the demo project, there is a separate build configuration for each supported languages. In order to activate a specific configuration:

1. Click `Project` > `Build Configuration` > `Set Active`
2. Select the target configuration

Then, to compile and run the demo project on a STM32f411 discovery board, perform the following steps:

1. Open STM32CubeIDE
2. Click `File` > `Open Projects from file system...` to display the `Import Projects` dialog box. Select the [stm32f469i-disco](./stm32f411e-disco) folder from this repository, and then press the `Finish` button.
3. Copy the `Inc` and `Lib` folders from the downloaded **PCM2PDM** library to [/Middlewares/ST/STM32_Audio/Addons/PDM](./stm32f411e-disco/Middlewares/ST/STM32_Audio/Addons/PDM)
4. Select the `stm32f411e-disco-demo` project inside the `Project Explorer` window
5. Replace `ACCESS_KEY` in both `main.c` and `main_multi.c` with your AccessKey obtained from [Picovoice Console](https://picovoice.ai/console/)
5. Click `Project` > `Build Project`
6. Connect the board to the computer and press `Run` > `Debug`
7. There are two build configurations in this project: Single wake word demo, and Multiple wake words demo; choose one of them in the `Qualifier` window and press `ok`

> :warning: `printf()` uses the SWO connector and the trace port 0. For more information, refer to [STM32 microcontroller debug toolbox](https://www.st.com/resource/en/application_note/dm00354244-stm32-microcontroller-debug-toolbox-stmicroelectronics.pdf), Chapter 7.

For the single wake word demos, the default wake words are:

- `Porcupine` for English language,
- `salut ordinateur` for French language.
- `hey computer` for German language,
- `hola computadora` for Spanish language,

Below are the LED colors associated with supported wake words for the multiple wake words demo:

- ![#00ff00](https://via.placeholder.com/15/00ff00/000000?text=+) `Porcupine`
- ![#ff8000](https://via.placeholder.com/15/ff8000/000000?text=+) `Picovoice`
- ![#ff0000](https://via.placeholder.com/15/ff0000/000000?text=+) `Bumblebee`
- ![#0000ff](https://via.placeholder.com/15/0000ff/000000?text=+) `Alexa`

## Create Custom Wake Word

1. Copy the UUID of the board printed at the beginning of the session to the serial port monitor.
2. Go to [Picovoice Console](https://console.picovoice.ai/) to create a model for [Porcupine wake word engine](https://picovoice.ai/docs/quick-start/console-porcupine/).
3. Select `Arm Cortex-M` as the platform when training the model.
4. Select `STM32` as the board type and provide the UUID of the chipset on the board.

The model is now being trained. You will be able to download it within a few hours.

## Import the Custom Wake Word

1. Download your custom voice model(s) from [Picovoice Console](https://console.picovoice.ai/).
2. Decompress the zip file. The model for Porcupine wake word is located in two files: A binary `.ppn` file, and as a `.h` header file containing a `C` array version of the binary model.
3. Copy the contents of the array inside the `.h` header file and update the `DEFAULT_KEYWORD_ARRAY` value in [/stm32f411e-disco/Inc/pv_params.h](./stm32f411e-disco/Inc/pv_params.h) in the language section for which the model is trained.
