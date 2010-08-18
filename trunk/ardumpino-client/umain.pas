{
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
}

unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ComCtrls, Synaser, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Log: TMemo;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    Status: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;

implementation

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  StrData: String;
  ROMSize: Integer;
  ROMData: PByte;
  ROMFile: TFileStream;
  Serial: TBlockSerial;

begin
  if Trim(Edit1.Text) = '' then begin
    Application.MessageBox('You must select the ROM file name', 'Warning', MB_OK);
    Edit1.SetFocus;
    Exit;
  end;

  Serial := TBlockSerial.Create;
  ROMData := nil;
  ROMFile := nil;

  Log.Clear;

  GroupBox1.Enabled := False;
  Screen.Cursor := crHourGlass;

  try

    try
      Log.Lines.Add('Opening serial port.');
      Serial.Connect(ComboBox1.Text);
      Serial.Config(115200, 8, 'N', SB1, False, False);

      Sleep(2000);

      Log.Lines.Add('Reading ROM size in bytes...');
      Serial.SendString('GET_GENESIS_ROMSIZE' + CR);

      StrData := Serial.Recvstring(1000);
      ROMSize := StrToInt(StrData);

      Log.Lines.Add('Allocating memory for ROM data (' + StrData + ') bytes.');
      ROMData := Getmem(ROMSize);
      FillChar(ROMData^, ROMSize, 0);

      Log.Lines.Add('Dumping ROM data...');
      Serial.SendString('READ_GENESIS_ROM' + CR);

      i := 0;

      while i < ROMSize do begin
        ROMData[i] := Serial.RecvByte(1000);
        Status.SimpleText := 'Dumping ROM... ' + IntToStr(i * 100 div ROMSize) + '% completed.';
        Application.ProcessMessages;
        Inc(i);
      end;

      Log.Lines.Add('Saving ROM to file.');
      ROMFile := TFileStream.Create(Edit1.Text, fmOpenReadWrite or fmCReate);
      ROMFile.Write(ROMData^, ROMSize);

      Log.Lines.Add('Done!');
    finally
      Serial.Free;

      if ROMData <> nil then
        Freemem(ROMData);

      if ROMFile <> nil then
        ROMFile.Free;

      Status.SimpleText := 'Ready';

      GroupBox1.Enabled := True;
      Screen.Cursor := crDefault;
    end;

  except
    on E: Exception do begin
      Log.Lines.Add('An error has occurred: ' + E.Message);
      //Application.MessageBox(PChar('An error has occurred: ' + CR + LF + E.Message), 'Error', MB_OK);
    end;
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Edit1.Text := SaveDialog1.FileName;
end;


initialization
  {$I umain.lrs}

end.

