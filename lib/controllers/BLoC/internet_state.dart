part of 'internet_cubit.dart';

abstract class InternetStates {}

class InternetInitial extends InternetStates {}

class InternetConnectionLoadingState extends InternetStates {}

class InternetConnectionNoState extends InternetStates {}

class InternetConnectionAvailableState extends InternetStates {}

class InternetHandleWebViewLoadingState extends InternetStates {}

class InternetHandleWebViewSuccesState extends InternetStates {}

class ToggleScreenState extends InternetStates {}
