import com.nativelibs4java.util.*; 
import com.nativelibs4java.opencl.*;
import org.bridj.Pointer;
import java.util.logging.*;

class MyCL {
  private CLContext context;
  private CLQueue queue;
  private CLKernel kernel;
  
  private boolean isCalcing = false;
  private int n = 1;
  private Pointer<Float> outPtr;  
  private CLBuffer<Float> a,b, out;
  private CLProgram program; 
  private Pointer<Float> aPtr, bPtr, cPtr;
  
  private int[] nextUpdateIn;
  public  float[] distances;
  public  float[] xs;
  public  float[] ys;
  public  float[] zs;
   
  public MyCL(int aN) {
    Logger log = LogManager.getLogManager().getLogger("");
    for (Handler h : log.getHandlers()) {
      h.setLevel(Level.WARNING);
    }
  
    context = JavaCL.createBestContext(com.nativelibs4java.opencl.CLPlatform.DeviceFeature.GPU);
    queue = context.createDefaultQueue();
    
    n = aN;
    aPtr = org.bridj.Pointer.allocateFloats(n);
    bPtr = org.bridj.Pointer.allocateFloats(n);
    cPtr = org.bridj.Pointer.allocateFloats(n);
  
    setupInput(0);
  
    // Create OpenCL input buffers (using the native memory pointers aPtr and bPtr) :
    a = context.createBuffer(com.nativelibs4java.opencl.CLMem.Usage.Input, aPtr);
    b = context.createBuffer(com.nativelibs4java.opencl.CLMem.Usage.Input, bPtr);
  
    // Create an OpenCL output buffer :
    out = context.createBuffer(com.nativelibs4java.opencl.CLMem.Usage.Output, cPtr);
  
    // Read the program sources and compile them :
    String src = join(loadStrings(dataPath("testcl1.cl") ), "\n");
    program = context.createProgram(src);
  
    kernel = program.createKernel("add_floats");
    kernel.setArgs(a, b, out, n);
  }
   
  public void callKernelGetOutput() {
    if (!isCalcing) {
      isCalcing = true;
      a.write(queue, aPtr, true, null);
      b.write(queue, bPtr, true, null);    
      CLEvent addEvt = kernel.enqueueNDRange(queue, new int[] { n });
      outPtr = out.read(queue, addEvt); // blocks until add_floats finished
      isCalcing = false;
    }
  }
  
  void setupInput(int j) {
    for (int i = 0; i < n; i++) {
      aPtr.set(i, (float)(0.3 * cos(j * 0.1 + i * 0.3234)));
      bPtr.set(i, (float)(1.0 * sin(j * 0.1 + i * 0.05)));
    }  
  }
  
  float[] getOutput() {
    float[] outs = new float[n];
    for (int i = 0; i < n; i++) {
      outs[i] = outPtr.get(i);
    }
    return outs;
  }

}
