import themidibus.*; //Import the library

class MidiInput {
  //nanokontrol: sliders = 0:7, knobs = 16:23, 
  // rew 43, ff 44, stop 42, play 41, rec 45
  // cycle 46, set 60, markerleft 61, markerright 62
  // trackleft 52, trackright 59
  // solo buttons = 32:39
  // mute buttons = 48:55
  // record buttons = 64:71
  
  MidiBus myBus; // The MidiBus
  Slider[] sliders = new Slider[127];
  Slider[] knobs = new Slider[127];
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
        //sliders
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
            PVector p = slider.getPosition();
            cf.activeSliderY = round(p.y);
          }
          break;
        
        //knobs      
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
          Slider knob = knobs[number];
          if (knob != null) {
            knob.setValue( (knob.getMax() - knob.getMin()) * 
                             (float(value) / 127.0) + 
                             knob.getMin() );
            PVector p1 = knob.getPosition();
            cf.activeSliderY = round(p1.y);                             
          }
          break;
        
        case 41:
          play();
          break;
          
        case 42:
          myStop();
          break;
        
        case 65:
          if (value > 64) {
            inputData.peakinessToParticleYVelocity = !inputData.peakinessToParticleYVelocity;
            cf.updateCheckboxes();
          }
          break;
          
        case 66:
          if (value > 64) {
            inputData.dVdtToParticleXVelocity = !inputData.dVdtToParticleXVelocity;
            cf.updateCheckboxes();
          }
          break;
          
        default:
          println(number);
          break;
      }
    }
  }
  
  private void plugControllerSlider (int controllerNumber, Slider slider) {
    if (available) {
      if ((controllerNumber >= 0) && (controllerNumber <= 127)) {
        sliders[controllerNumber] = slider;  
      } 
    }
  }
  
  private void plugControllerKnob (int controllerNumber, Slider slider) {
    if (available) {
      if ((controllerNumber >= 0) && (controllerNumber <= 127)) {
        knobs[controllerNumber] = slider;  
      } 
    }
  }  

}
