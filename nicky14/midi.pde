import themidibus.*; //Import the library

class MidiInput {

  MidiBus myBus; // The MidiBus
  Slider[] sliders = new Slider[127];
  Boolean available = false;

  MidiInput (PApplet parent) {
    //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    
    available = MidiBus.availableInputs().length > 0;

    if (available) {
      int input = 0;
      println("Using midi input " , input , "   " , MidiBus.availableInputs()[input]);
      myBus = new MidiBus(parent , input , -1);
    } else {
      println("No midi input devices detected");
    }
  }
  
  public void controllerChange(int channel, int number, int value) {
    if (available) {
      switch (number) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          Slider slider = sliders[number];
          if (slider != null) {
            slider.setValue( (slider.getMax() - slider.getMin()) * 
                             (float(value) / 127.0) + 
                             slider.getMin() );
          }
          break;
        
              
        case 16:
          //first knob
        
          break;
        
        default:
          break;
      }
    }
  }
  
  private void plugControllerToControlFrameSlider (int controllerNumber, Slider slider) {
    if (available) {
      if ((controllerNumber >= 0) && (controllerNumber <= 127)) {
        sliders[controllerNumber] = slider;  
      } 
    }
  }

}
