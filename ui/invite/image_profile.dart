import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/user/user_bloc.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/style.dart';

class ImageProfile extends StatefulWidget {
  const ImageProfile({
    Key key,
    @required this.size,
  }) : super(key: key);

  final double size;

  @override
  _ImageProfileState createState() => _ImageProfileState();
}

class _ImageProfileState extends State<ImageProfile> {
  String resizedImage;

  @override
  void initState() {
    UserBloc()
        .getOptmizedProfileImageSize(
            deviceWidth: (Style.horizontal(100) * Style.devicePixelRatio),
            user: AuthenticationState().user)
        .then((value) => setState(() => resizedImage = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);

    if (authenticationState.storageTaskEventType == storage.TaskState.running) {
      return Container(
        height: widget.size,
        width: widget.size,
        child: ClipRRect(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
      );
    } else {
      return Container(
        key: Key("profile_image"),
        height: widget.size,
        width: widget.size,
        child: ClipRRect(
          child: authenticationState.user.imageProfile == null
              ? _buildInitialLetters(authenticationState)
              : _buildImage(authenticationState),
          borderRadius: BorderRadius.circular(widget.size),
        ),
      );
    }
  }

  Widget _buildImage(AuthenticationState authenticationState) {
    return CachedNetworkImage(
      imageUrl: resizedImage ?? authenticationState.user.imageProfile,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, a) => Text(
          "${authenticationState.user.name[0]}${authenticationState.user.lastName[0]}"
              .toUpperCase()),
    );
  }

  Widget _buildInitialLetters(AuthenticationState authenticationState) {
    return Container(
      color: Style.brandColor,
      child: Center(
        child: Text(
          "${authenticationState.user.name[0]}${authenticationState.user.lastName[0]}"
              .toUpperCase(),
          style: Style.mainTheme.appBarTheme.textTheme.headline6,
        ),
      ),
    );
  }
}
