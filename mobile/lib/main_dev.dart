import 'package:flutter/material.dart';
import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/main.dart';

void main() {
  final devConfig = AppConfig(
    appName: 'USA Visa Dev',
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.usavpc.app',
    // Using REAL Cloud Credentials from .env.local
    supabaseUrl: 'https://inaxjdmofqbcoljxgnwr.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYXhqZG1vZnFiY29sanhnbndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2ODM3MjcsImV4cCI6MjA4MDI1OTcyN30.zTcpvbRKcWJ4ecPKxgWUUvTaYC7wpB2s8SxFxE3IH8c',
    netlifyFunctionsUrl: 'https://usavpc.org', // Real Live URL
  );

  mainCommon(devConfig);
}
