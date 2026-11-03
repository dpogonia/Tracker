[Русский](README.md) | **English**

# Tracker

A habit tracker for iPhone. A project from the Yandex Practicum iOS course.

Brief: [iOS-TrackerApp-Public](https://github.com/Yandex-Practicum/iOS-TrackerApp-Public). Design: [Figma](https://www.figma.com/design/owAO4CAPTJdpM1BZU5JHv7/Tracker).

## Purpose

The app helps people build useful habits and keep track of whether they follow them.

Goals:

- track habits by weekday;
- see progress on those habits.

## Summary

The user creates tracker cards. A card has a name, a category, and a schedule, plus an emoji and a color so the cards are easy to tell apart.

Cards are grouped by category. They can be searched and filtered.

The calendar shows which habits are planned for a chosen day.

Statistics show successful results, progress, and averages.

## What it does

A habit repeats on the weekdays you choose. An irregular event is not tied to particular days.

On the main screen, cards are grouped by category. You can search by name, filter them, and open a day in the calendar. A card can be pinned, edited, or deleted.

The Statistics tab has four numbers:

- best period — the longest streak of days without a break;
- perfect days — days when every planned habit was completed;
- trackers completed — how many times habits were checked off;
- average — how many habits are completed per day.

The first launch shows onboarding. Dark mode follows the system setting.

## Stack

UIKit, Core Data, iOS 17. The project also includes AppMetrica analytics, localization, and snapshot tests.

## Run

```bash
git clone https://github.com/dpogonia/Tracker-YANDEX.git
cd Tracker-YANDEX
open Tracker.xcodeproj
```

Run the **Tracker** scheme on an iPhone simulator with iOS 17.

## Author

[Dmitrii Pogonia](https://github.com/dpogonia)
