/*
  ArDUMPino
  Copyright (c) 08/2010 - Bruno Freitas - bootsector@ig.com.br

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/* Maximum string size for serialReadString() function*/
#define MAX_SERIAL_STRING_SIZE 128

/* ROM address SPI pins */
int addrClockPin = 3;
int addrLatchPin = 4;
int addrDataPin = 5;

/* ROM data SPI pins */
int dataClockPin = 8;
int dataLatchPin = 9;
int dataDatapin = 10;

/* Command received via serial port */
char *command;

void setup() {
	pinMode(addrClockPin, OUTPUT);
	pinMode(addrLatchPin, OUTPUT);
	pinMode(addrDataPin, OUTPUT);

	pinMode(dataClockPin, OUTPUT);
	pinMode(dataLatchPin, OUTPUT);
	pinMode(dataDatapin, INPUT);

	Serial.begin(115200);
}

void loop() {
	for (;;) {
		command = serialReadString();

		//delay(1000);

		if (strncasecmp(command, "READ_GENESIS_ROM", MAX_SERIAL_STRING_SIZE) == 0) {
			readGenesisROM();
		} else if (strncasecmp(command, "GET_GENESIS_ROMSIZE", MAX_SERIAL_STRING_SIZE) == 0) {
			printGenesisROMSize();
		} else {
			Serial.println("Command unknown.");
		}
	}
}

word shiftIn16bit(int clockPin, int latchPin, int dataPin) {
	word data = 0;
	int i = 15;

	digitalWrite(latchPin, LOW);
	digitalWrite(clockPin, LOW);

	digitalWrite(latchPin, HIGH);
	delayMicroseconds(1);
	digitalWrite(latchPin, LOW);

	do {
		data |= digitalRead(dataPin) << i;

		digitalWrite(clockPin, HIGH);
		delayMicroseconds(1);
		digitalWrite(clockPin, LOW);

		i--;
	} while (i >= 0);

	return data;
}

void shiftOut24bit(int clockPin, int latchPin, int dataPin, unsigned long value) {
	digitalWrite(latchPin, LOW);
	shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x00FF0000) >> 16);
	shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x0000FF00) >> 8);
	shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x000000FF));
	digitalWrite(latchPin, HIGH);
}

char *serialReadString() {
	static char serialString[MAX_SERIAL_STRING_SIZE];
	int c = 0;
	int count = 0;

	serialString[0] = 0;

	do {
		if (Serial.available() > 0) {
			c = Serial.read();

			if (c == 13)
				break;

			serialString[count++] = (char) c;
		}
	} while (count < MAX_SERIAL_STRING_SIZE - 1);

	serialString[count] = 0;

	return serialString;
}

long getGenesisROMSize() {
	long w1, w2;

	shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, 0xD2);
	w1 = shiftIn16bit(dataClockPin, dataLatchPin, dataDatapin);

	shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, 0xD3);
	w2 = shiftIn16bit(dataClockPin, dataLatchPin, dataDatapin);

	return ((w1 << 16) | w2) + 1;
}

void readGenesisROM() {
	unsigned long addr;
	long romSize;
	word data;
	//char hexOutput[10];

	romSize = getGenesisROMSize();

	for (addr = 0; addr < romSize / 2; addr++) {
		shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, addr);
		data = shiftIn16bit(dataClockPin, dataLatchPin, dataDatapin);

		//sprintf(hexOutput, "%.2X%.2X", (data & 0xFF00) >> 8, data & 0xFF);
		//Serial.print(hexOutput);

		Serial.print((data & 0xFF00) >> 8, BYTE);
		Serial.print(data & 0xFF, BYTE);
	}
}

void printGenesisROMSize() {
	Serial.println(getGenesisROMSize());
}

