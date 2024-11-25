import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stayegy/bloc/FormBloc/Form_Bloc.dart';
import 'package:stayegy/bloc/FormBloc/Form_Events.dart';
import 'package:stayegy/bloc/FormBloc/Form_States.dart';
import 'package:stayegy/bloc/Login_Bloc/LogIn_Bloc.dart';
import 'package:stayegy/bloc/Login_Bloc/LogIn_Events.dart';
import 'package:stayegy/bloc/Login_Bloc/LogIn_State.dart';
import 'package:stayegy/constants/ConstantLists.dart';
import 'package:stayegy/container/SnackBar.dart';
import 'package:stayegy/container/bottom_button.dart';
import 'package:stayegy/container/loading_Overlay.dart';

class AccountDetailsPage extends StatefulWidget {
  AccountDetailsPage({Key key}) : super(key: key);

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  String _name = "";
  String _email = "";
  File imageFile = null;

  @override
  Widget build(BuildContext context) {
    final FormBloc formBloc = BlocProvider.of<FormBloc>(context);
    final LogInBloc logInBloc = BlocProvider.of<LogInBloc>(context);

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0.0,
            leading: IconButton(
              padding: EdgeInsets.only(right: 20),
              iconSize: 5,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.back,
                color: Color(0xff191919),
                size: 30,
              ),
            ),
            title: Text(
              'Account Details',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(left: 15, right: 15),
            child: SingleChildScrollView(
              child: BlocListener<FormBloc, FormStates>(
                listener: (context, state) {
                  if (state is NameFieldValidState) {
                    logInBloc.add(UpdateUserDetailsEvent(operationType: 'name', name: _name));
                  } else if (state is EmailFieldValidState) {
                    logInBloc.add(UpdateUserDetailsEvent(operationType: 'email', email: _email));
                  } else if (state is ImagePickedFailedState) {
                    SnackBarBuilder().buildSnackBar(context, message: 'Failed to load image.', color: Colors.red);
                  } else if (state is ImagePickedState) {
                    imageFile = File(state.pickedFile.path);
                  }
                },
                child: BlocBuilder<LogInBloc, LogInState>(buildWhen: (previous, currentState) {
                  if (currentState is UpdateUserDetailsCompleteState) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    return true;
                  } else if (currentState is LoadingState) {
                    LoadingOverlay().buildOverlay(context);
                  }
                  return false;
                }, builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      accountDetailsText('photoChange', '', context, formBloc: formBloc, logInBloc: logInBloc, imageURL: userDetailsGlobal.picURL),
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: accountDetailsText('Full Name', userDetailsGlobal.name != null ? userDetailsGlobal.name : 'Mr. XYZ', context, logInBloc: logInBloc, formBloc: formBloc),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: accountDetailsText('Email', userDetailsGlobal.email != null ? userDetailsGlobal.email : 'stayegy@outlook.com', context, logInBloc: logInBloc, formBloc: formBloc),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'GENDER',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Radio(activeColor: Color(0xff191919), value: 'MALE', groupValue: userDetailsGlobal.gender, onChanged: (value) {}),
                                  Text('MALE'),
                                  Radio(activeColor: Color(0xff191919), value: 'FEMALE', groupValue: userDetailsGlobal.gender, onChanged: (value) {}),
                                  Text('FEMALE'),
                                  Radio(activeColor: Color(0xff191919), value: 'OTHER', groupValue: userDetailsGlobal.gender, onChanged: (value) {}),
                                  Text('OTHER'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ));
  }

  Column accountDetailsText(String titletxt, String fieldtxt, BuildContext context, {FormBloc formBloc, LogInBloc logInBloc, String imageURL = null}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titletxt != 'photoChange'
            ? Text(
                titletxt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Container(),
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: () {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => Scaffold(
                body: BlocBuilder<FormBloc, FormStates>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titletxt == 'Full Name'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                                child: TextField(
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z .]')),
                                  ],
                                  onChanged: (value) => _name = value,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    labelText: 'Full Name',
                                    hintText: 'ENTER YOUR FULL NAME',
                                    // enabledBorder: OutlineInputBorder(
                                    //   borderRadius: BorderRadius.circular(0),
                                    //   borderSide: BorderSide(
                                    //     color: Colors.black,
                                    //   ),
                                    // ),
                                    //border: OutlineInputBorder(),
                                    errorText: state is NameFieldEmptyState ? 'This field can not be empty!' : null,
                                  ),
                                ),
                              )
                            : titletxt == 'Email'
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                                    child: TextField(
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) => _email = value,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                        labelText: 'Email',
                                        hintText: 'ENTER YOUR EMAIL ADDRESS',
                                        // enabledBorder: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.circular(0),
                                        //   borderSide: BorderSide(
                                        //     color: Colors.black,
                                        //   ),
                                        // ),
                                        // border: OutlineInputBorder(),
                                        errorText: state is EmailFieldEmptyState
                                            ? 'This field can not be empty!'
                                            : state is EmailFieldNotValidState
                                                ? 'Email format is not valid!'
                                                : null,
                                      ),
                                    ),
                                  )
                                : titletxt == 'photoChange'
                                    ? Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            print('Upload Button pressed!');
                                            formBloc.add(GetImageEvent());
                                          },
                                          child: Container(
                                            ///Todo: Take photo from gallery
                                            child: Stack(
                                              children: <Widget>[
                                                CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  radius: 100.0,
                                                  child: state is ImagePickedState
                                                      ? ClipOval(
                                                          child: Image.file(
                                                            File(state.pickedFile.path),
                                                            fit: BoxFit.cover,
                                                            width: 200,
                                                          ),
                                                        )
                                                      : Container(
                                                          padding: EdgeInsets.only(
                                                            top: 15,
                                                          ),
                                                          child: Image.asset(
                                                            'images/avater.png',
                                                          ),
                                                        ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 3,
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                          child: Column(
                            children: <Widget>[
                              BottomButton(
                                  text: 'UPDATE',
                                  disabled: false,
                                  onTap: () {
                                    print("Pressed");
                                    print(_name);
                                    print(_email);
                                    switch (titletxt) {
                                      case 'Full Name':
                                        formBloc.add(NameValidationCheckEvent(name: _name));
                                        // if (state is NameFieldValidState) {
                                        //   // logInBloc.add(UpdateUserDetailsEvent(operationType: 'name', name: _name));
                                        // }
                                        break;
                                      case 'Email':
                                        formBloc.add(EmailValidationCheckEvent(email: _email));
                                        // if (state is EmailFieldValidState) {
                                        //   // logInBloc.add(UpdateUserDetailsEvent(operationType: 'email', email: _email));
                                        // }
                                        break;
                                      case 'photoChange':
                                        if (imageFile != null) {
                                          logInBloc.add(UpdateUserDetailsEvent(operationType: 'photo', image: imageFile));
                                        }
                                    }
                                  })
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
          child: titletxt == 'photoChange'
              ? Container(
                  // show photo of the user
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 50.0,
                        child: imageURL != ""
                            ? ClipOval(
                                child: Image.network(
                                  imageURL,
                                  fit: BoxFit.cover,
                                  width: 100,
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 15),
                                child: Image.asset(
                                  'images/avater.png',
                                ),
                              ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 3,
                      //   child: Icon(
                      //     Icons.add_a_photo,
                      //     color: Colors.black,
                      //     size: 20,
                      //   ),
                      // ),
                    ],
                  ),
                )
              : Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fieldtxt,
                            style: TextStyle(color: Color(0xff6b6b6b)),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      Divider(
                        height: 20,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
