[Русский](README.md) | **English**

# Tracker

A habit tracker for iPhone. A Yandex Practicum iOS course project: you add habits and mark them as done.

The description and goals follow the [Yandex brief](https://github.com/Yandex-Practicum/iOS-TrackerApp-Public). Design: [Figma](https://www.figma.com/design/owAO4CAPTJdpM1BZU5JHv7/Tracker).

## What it does

A habit repeats on the weekdays you choose. An irregular event is not tied to particular days. Each card has a name, a category, an emoji, and a color.

On the main screen, cards are grouped by category. You can search by name, filter them, and open a day in the calendar. A card can be pinned, edited, or deleted.

The Statistics tab has four numbers:

- best period — the longest streak of days without a break
- perfect days — days when every planned habit was completed
- trackers completed — how many times habits were checked off
- average — how many habits are completed per day

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
