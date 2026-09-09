    /*

    AUTH GATE - This will continously listen for auth state changes.
    ----------------------------------------------------------------

    unauthenticated --> Login
    authenticated --> Profile Page

    */

    import 'package:docelix_mobileapp/ui/land_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget{
 const AuthGate({super.key});

 Widget build(BuildContext context){

   final supabase = Supabase.instance.client;

   return StreamBuilder<AuthState>(
     // Listen to auth state changes
       stream: supabase.auth.onAuthStateChange,
      // stream: Supabase.instance.client.auth.onAuthStateChange,

       // Build appropriate page based on auth state
         builder: (context, snapshot){
           // loading....
           if(snapshot.connectionState == ConnectionState.waiting) {
             return const Scaffold(
               body: Center(child: CircularProgressIndicator(),),
             );
           }

           final session = snapshot.data?.session;

           // -----------------------------------------------------
           // AUTHENTICATED
           // -----------------------------------------------------

           if (session != null) {
             return LandScreen();
           }

           return LoginScreen();
          // final session = snapshot.hasData ? snapshot.data!.session : null;

           /*if(session != null){
             return LandScreen();
           } else {
             return LoginScreen();
           }*/
         }
       );
    }

}