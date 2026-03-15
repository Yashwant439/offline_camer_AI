Place your offline model files here.

Suggested structure:
assets/models/vision/
  - mobilenet_v3.tflite
  - labels.txt
assets/models/llm/
  - tinyllama-q4_0.gguf
assets/models/stt/
  - whisper-tiny.onnx

Update model IDs and URLs in lib/ai/runanywhere_service.dart to match your model files.
