import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinmajur_customer/configs/services/socket/socket_provider.dart';

class SocketStatusWidget extends StatelessWidget {
  final bool showText;
  final bool showFullStatus;
  final double iconSize;
  final TextStyle? textStyle;

  const SocketStatusWidget({
    Key? key,
    this.showText = true,
    this.showFullStatus = false,
    this.iconSize = 16.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, socketProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Color(socketProvider.statusColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Color(socketProvider.statusColor).withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Icon
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Color(socketProvider.statusColor),
                  shape: BoxShape.circle,
                  boxShadow: socketProvider.isConnected
                      ? [
                    BoxShadow(
                      color: Color(socketProvider.statusColor).withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ]
                      : null,
                ),
                child: socketProvider.isConnecting
                    ? Center(
                  child: SizedBox(
                    width: iconSize * 0.6,
                    height: iconSize * 0.6,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
                    : Icon(
                  socketProvider.isConnected
                      ? Icons.wifi
                      : socketProvider.connectionError != null
                      ? Icons.error_outline
                      : Icons.wifi_off,
                  size: iconSize * 0.7,
                  color: Colors.white,
                ),
              ),

              // Status Text
              if (showText) ...[
                SizedBox(width: 6.0),
                Text(
                  socketProvider.statusText,
                  style: textStyle ??
                      TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(socketProvider.statusColor),
                      ),
                ),
              ],

              // Full Status Details
              if (showFullStatus && socketProvider.lastActivity != null) ...[
                SizedBox(width: 4.0),
                Text(
                  '• ${_formatLastActivity(socketProvider.lastActivity!)}',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatLastActivity(String lastActivity) {
    try {
      final dateTime = DateTime.parse(lastActivity);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

// Socket Status Dialog - For detailed status view
class SocketStatusDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, socketProvider, child) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.settings_ethernet,
                color: Color(socketProvider.statusColor),
              ),
              SizedBox(width: 8),
              Text('Socket Connection Status'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow('Status', socketProvider.statusText, socketProvider.statusColor),
              SizedBox(height: 8),
              _buildStatusRow(
                'Connected',
                socketProvider.isConnected ? 'Yes' : 'No',
                socketProvider.isConnected ? 0xFF4CAF50 : 0xFFF44336,
              ),
              if (socketProvider.isConnecting) ...[
                SizedBox(height: 8),
                _buildStatusRow('State', 'Connecting...', 0xFFFFA726),
              ],
              if (socketProvider.connectionError != null) ...[
                SizedBox(height: 8),
                _buildStatusRow('Error', socketProvider.connectionError!, 0xFFF44336),
              ],
              if (socketProvider.lastActivity != null) ...[
                SizedBox(height: 8),
                _buildStatusRow('Last Activity', _formatDateTime(socketProvider.lastActivity!), 0xFF2196F3),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!socketProvider.isConnected && !socketProvider.isConnecting) {
                  socketProvider.reconnect();
                }
                Navigator.of(context).pop();
              },
              child: Text(socketProvider.isConnected ? 'Close' : 'Retry'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, int color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Color(color),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}

// Socket Status Floating Button - For easy access
class SocketStatusFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, socketProvider, child) {
        return FloatingActionButton(
          mini: true,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SocketStatusDialog(),
            );
          },
          backgroundColor: Color(socketProvider.statusColor),
          child: socketProvider.isConnecting
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Icon(
            socketProvider.isConnected
                ? Icons.wifi
                : Icons.wifi_off,
            size: 16,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

// Socket Status AppBar Widget
class SocketStatusAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SocketStatusAppBarWidget({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (actions != null) ...actions!,
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SocketStatusDialog(),
                );
              },
              child: SocketStatusWidget(
                showText: false,
                iconSize: 20.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}