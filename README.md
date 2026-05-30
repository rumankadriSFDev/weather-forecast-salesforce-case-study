# Weather Forecast Search Application

## Overview

This Salesforce application allows users to select a pre-configured city and a forecast date, retrieve hourly weather forecast data from the Open-Meteo API, and log each search for reporting and analysis purposes.

## Features

### User Story 1 - Weather Forecast Search

* Select a city from a pre-configured list maintained in Custom Metadata.
* Select a forecast date (today or future dates only).
* Retrieve hourly temperature forecasts from the Open-Meteo API.
* Display:

  * City
  * Forecast Date
  * Timezone
  * Hourly Time List
  * Hourly Temperature List
* Error handling for API and system failures.

### User Story 2 - Weather Search Logging

Each successful search creates a Weather Search record containing:

* User Name
* Search Date/Time
* Forecast Date
* Location
* Timezone

Search history can be viewed through Salesforce Reports.

---

## Technical Design

### Salesforce Components

#### Flow

* Weather_Forecast_Search_Flow

#### Apex

* weatherForecastFlowHelper
* weatherForecastFlowHelperTest

#### Custom Metadata

* Weather_City__mdt

#### Custom Object

* Weather_Search__c

#### External Integration

* Open-Meteo Weather API

---

## Supported Cities

### India

* Mumbai
* Delhi
* Bengaluru
* Chennai
* Hyderabad
* Kolkata
* Pune

### International

* London
* New York
* Tokyo
* Paris
* Sydney
* Dubai

---

## Integration Details

Weather data is retrieved using the Open-Meteo API:

https://api.open-meteo.com

The application retrieves hourly temperature forecasts based on the selected city and forecast date.

---

## Report

Report Name:

Weather Search History Report

Available Fields:

* User Name
* Forecast Date
* Search DateTime
* Location
* Timezone

---

## Custom Salesforce App

A custom Lightning application named **Weatherly** was created to provide a dedicated user experience for the Weather Forecast solution.

The app includes:
- Weather Forecast Search Flow
- Weather Search History Records
- Weather Search Reports

---

## Deployment Steps

1. Deploy metadata to Salesforce Org.
2. Ensure Remote Site Setting for Open-Meteo is configured.
3. Verify Weather City Custom Metadata records are available.
4. Activate Weather_Forecast_Search_Flow.
5. Run the application.

---

## AI Usage Declaration

During the development of this solution, AI tools were used occasionally to support the development process and help resolve technical challenges.

Specifically, AI was used for:

* Reviewing and improving Apex test classes to ensure adequate code coverage and test quality.
* Troubleshooting Apex compilation and deployment issues encountered during development.
* Discussing alternative implementation approaches and validating design decisions.
* Suggesting minor code optimizations and improvements to error handling.
