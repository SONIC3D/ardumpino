![http://i82.photobucket.com/albums/j267/bootsector/ArDUMPino-3dboard.jpg](http://i82.photobucket.com/albums/j267/bootsector/ArDUMPino-3dboard.jpg)

ArDUMPino is a game cartridge ROM reader/dumper based on Arduino.

Current version supports reading SEGA Genesis cartridges, but it can be extended to support other platforms.

ArDUMPino is composed of the following components:

**Hardware**

  * Arduino board (or any other Arduino compatible board)

  * Cartridge board (custom made - please refer to schematics)

**Software**

  * ArDUMPino - Runs in the Arduino micro controller. Does all the ROM reading.

  * ArDUMPino Client - GUI application created with Lazarus (FreePascal). Connects to the Arduino running the ArDUMPino sketch and communicates with it, capturing all the information being outputted by the Arduino.

**Screenshot**

![http://i82.photobucket.com/albums/j267/bootsector/ArDUMPino-Client.png](http://i82.photobucket.com/albums/j267/bootsector/ArDUMPino-Client.png)

More info available from: http://www.brunofreitas.com/?q=node/31