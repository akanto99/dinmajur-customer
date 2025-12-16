import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';

class VoiceListTab extends StatefulWidget {
  final Function(String?)? onRecordingChanged;
  final String? initialRecordingPath; // ADD THIS PARAMETER
  final String? initialDuration; // ADD THIS PARAMETER (optional)

  const VoiceListTab({
    Key? key,
    this.onRecordingChanged,
    this.initialRecordingPath, // ADD THIS
    this.initialDuration, // ADD THIS
  }) : super(key: key);

  @override
  State<VoiceListTab> createState() => _VoiceListTabState();
}

class _VoiceListTabState extends State<VoiceListTab> {
  bool _isRecording = false;
  bool _hasRecording = false;
  String _recordingDuration = "00:00";
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    // Initialize state from parent data
    _recordingPath = widget.initialRecordingPath;
    _hasRecording = widget.initialRecordingPath != null && widget.initialRecordingPath!.isNotEmpty;
    _recordingDuration = widget.initialDuration ?? "00:00";
  }

  // ADD THIS METHOD TO HANDLE UPDATES FROM PARENT
  @override
  void didUpdateWidget(VoiceListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state if parent data changed
    if (widget.initialRecordingPath != oldWidget.initialRecordingPath) {
      setState(() {
        _recordingPath = widget.initialRecordingPath;
        _hasRecording = widget.initialRecordingPath != null && widget.initialRecordingPath!.isNotEmpty;
        _recordingDuration = widget.initialDuration ?? "00:00";
      });
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording && !_hasRecording) {
        _hasRecording = true;
        _recordingPath = "voice_recording_${DateTime.now().millisecondsSinceEpoch}.wav";
        _recordingDuration = "01:23"; // Mock duration - replace with actual
      }
    });

    if (_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }

    _updateParent();
  }

  void _startRecording() {
    // TODO: Implement voice recording start logic
    print("Started recording...");
  }

  void _stopRecording() {
    // TODO: Implement voice recording stop logic
    print("Stopped recording...");
  }

  void _deleteRecording() {
    setState(() {
      _hasRecording = false;
      _isRecording = false;
      _recordingDuration = "00:00";
      _recordingPath = null;
    });
    _updateParent();
  }

  void _updateParent() {
    if (widget.onRecordingChanged != null) {
      widget.onRecordingChanged!(_recordingPath);
    }
  }

  void _playRecording() {
    // TODO: Implement audio playback
    print("Playing recording...");
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            border: Border(
              top: BorderSide.none,
              right: BorderSide(width: 1, color: AppColors.border(context)),
              left: BorderSide(width: 1, color: AppColors.border(context)),
              bottom: BorderSide(width: 1, color: AppColors.border(context)),
            ),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Column(children: [SizedboxSpaccing.height02(context), _buildRecordingArea(screenHeight, screenWidth), SizedboxSpaccing.height02(context)]),
        ),
        if (_hasRecording) ...[SizedboxSpaccing.height02(context), _buildRecordingControls()],
      ],
    );
  }

  Widget _buildRecordingArea(double screenHeight, double screenWidth) {
    return Container(
      height: 200,
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRecordingIcon(),
          SizedboxSpaccing.height01(context),
          _buildRecordingText(),
          if (_isRecording) ...[SizedboxSpaccing.height01(context), _buildRecordingDuration()],
          SizedboxSpaccing.height02(context),
          _buildRecordButton(screenHeight),
        ],
      ),
    );
  }

  Widget _buildRecordingIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Icon(_isRecording ? Icons.mic : Icons.mic, size: 35, color: _isRecording ? Colors.red : Colors.grey),
    );
  }

  Widget _buildRecordingText() {
    String text = _isRecording
        ? "Recording your shopping list..."
        : _hasRecording
        ? "Recording completed! You can play it back or record again."
        : "Record your shopping list by voice";

    return Text(
      text,
      style: AppTextStyles.textSize14(context, color: _isRecording ? Colors.red : Colors.grey),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecordingDuration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(_recordingDuration, style: AppTextStyles.textSize12(context, color: Colors.red)),
    );
  }

  Widget _buildRecordButton(double screenHeight) {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Container(
        width: screenHeight * 0.3,
        height: 48,
        decoration: BoxDecoration(color: _isRecording ? Colors.red : Colors.red, borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 20),
            SizedboxSpaccing.width01(context),
            Text(
              _isRecording ? "Stop Recording" : "Start Recording",
              style: AppTextStyles.textSize16(context, color: Colors.white, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.audiotrack, color: Colors.green, size: 20),
              SizedboxSpaccing.width02(context),
              Text("Voice Recording", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              const Spacer(),
              Text(_recordingDuration, style: AppTextStyles.textSize12(context, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(icon: Icons.play_arrow, label: "Play", onTap: _playRecording, color: Colors.green),
              _buildControlButton(icon: Icons.mic, label: "Re-record", onTap: _toggleRecording, color: Colors.orange),
              _buildControlButton(icon: Icons.delete, label: "Delete", onTap: _deleteRecording, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.textSize12(context, color: color)),
        ],
      ),
    );
  }
}
