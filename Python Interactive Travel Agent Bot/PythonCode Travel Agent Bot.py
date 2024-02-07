#MEMBERS: 1)JAIDEN ANGELES 2)DHRUV JINDAL
#DATE: APRIL 12, 2023
#ASGN: GROUP ASSIGNMENT 4
#STAGE: 2
#CLASS: CMPT 120 D100

# This code is a travel agent bot that helps you plan your perfect trip based on your preferences. It asks for your name, age, and how many nights you want to stay. Then, it reads information from files containing destinations, flight prices, hotel prices, and destination highlights. The bot suggests a trip based on your preferences and shows you the details including flight and hotel prices. You can then decide to book the trip or get another suggestion. If you choose to create an account, the bot provides a one-time password for you. Finally, the bot bids you goodbye and hopes to see you again soon.

#0. Import the modules
import csv
import random

#1. Define the welcome function
def welcome():
  print("Welcome to Travel Agent Bot! I will help you plan the trip according to your preferences. For that, I will ask you your name and provide you with a one-time password to create a user account. I hope you make good memories with us:")
  print()

#2. Define the function to ask user information
def ask_userinformation():
 print("What is your name? --> ", end = "")
 userName = input()
 print("What is your age? --> ", end = "")
 userAge = int(input())
 print("How many nights would you like to stay? --> ", end ="")
 userNights = int(input())
 return userName, userAge, userNights

#3. Define a function to read string lists from files
def read_string_list_from_file(file_name):
    with open(file_name, 'r') as file:
        return [line.rstrip('\n') for line in file]

#4. Define a function to read float lists from files
def read_float_list_from_file(file_name):
    with open(file_name, 'r') as file:
        return [float(line.rstrip('\n')) for line in file]

#5. Define a function to read dest highlights from files
def read_dest_highlights(file_name):
    dest_highlights = []
    with open(file_name, 'r') as file:
        for line in file:
            dest_highlights.append([bool(int(val)) for val in line.rstrip('\n').split(',')])
    return dest_highlights

#6. Define a function to append a line to a file
def append_line_to_file(line, file_name):
    with open(file_name, 'a') as file:
        file.write(line + '\n')

#7. Define a function to ask for a yes or no answer
def ask_yes_no(prompt):
    while True:
        answer = input(prompt).lower()
        if answer == 'y' or answer == 'n':
            return answer == 'y'

#8. Define a function to ask for a number
def ask_number(question):
  return int(input(question))

#9. Define a function to compute the total cost of a trip and sicount percentage
def compute_total_cost(destination, nights, age, destinations, flight_prices, hotel_prices):
    index = destinations.index(destination)
    flight_price = flight_prices[index]
    hotel_price = hotel_prices[index]

    senior_discount = max(0, age - 64) if age > 64 else 0
    total_price = flight_price + hotel_price * nights
    total_price *= 1 - senior_discount / 100

    return total_price

#10. Define a function to show trip details
def show_trip_details(destination, nights, age, destinations, flight_prices, hotel_prices):
    index = destinations.index(destination)
    flight_price = flight_prices[index]
    hotel_price = hotel_prices[index]
    senior_discount = max(0, age - 64) if age > 64 else 0
    total_price = compute_total_cost(destination, nights, age, destinations, flight_prices, hotel_prices)

    print(f"How about a trip to {destination}?")
    print(f"Flight: {flight_price:.2f} $")
    print(f"Hotel: {hotel_price:.2f} $/night")
    print(f"Discount: {senior_discount}%")
    print(f"Total for {nights} nights (incl. discounts): {total_price:.2f} $")

#11. Define the function to suggest a trip based on user preferences
def ask_user_preferences(highlights):
    preferences = []
    for highlight in highlights:
        preferences.append(ask_yes_no(f"Do you like {highlight}? Please answer y/n. --> "))
    return preferences

#12. Define a function for suggesting the trip
def suggest_trip(user_preferences, destinations, dest_highlights):
    max_matches = 0
    chosen_destination = -1

    for i, destination_highlights in enumerate(dest_highlights):
        matches = sum(preference and highlight for preference, highlight in zip(user_preferences, destination_highlights))
        if matches > max_matches:
            max_matches = matches
            chosen_destination = i

    if chosen_destination == -1:
        return "I am sorry, we currently have no trips that match your preferences at this point."
    else:
        return destinations[chosen_destination]

#13. Define the function to ask if the user wants to create an account
def ask_to_create_account():
 userResponse = ask_yes_no("Are you interested, and want to create a user account?")
 if userResponse:
  userName, userAge, _ = ask_userinformation()
  n = userAge % 8
  passwordBegin = userName[-1] * n
  passwordMiddle = userName[0]
  passwordEnd = "!" * random.randint(0, 5)
  userPassword = passwordBegin + passwordMiddle + passwordEnd
  print(f'Thanks for signing up! Your one-time password is: {userPassword}')
 else:
  print('Sorry to hear that. Please consider')
   
def write_user_data_to_csv(file_name, user_data):
    with open(file_name, mode='a', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(user_data)

#14. Finally, do the main function
def main():
    destinations = read_string_list_from_file("destinations.csv")
    highlights = read_string_list_from_file("highlights.csv")
    flight_prices = read_float_list_from_file("flight_prices.csv")
    hotel_prices = read_float_list_from_file("hotel_prices.csv")
    dest_highlights = read_dest_highlights("dest_highlights.csv")

    welcome()
    userName, userAge, userNights = ask_userinformation()
    name = userName
    age = userAge
    nights = userNights
  
    user_preferences = ask_user_preferences(highlights)
    user_data = [name, age] + [int(pref) for pref in user_preferences]
    write_user_data_to_csv("users.csv", user_data)
 
    while True:
        destination = suggest_trip(user_preferences, destinations, dest_highlights)
        if destination == "I am sorry, we currently have no trips that match your preferences at this point.":
            print(destination)
            break

        show_trip_details(destination, nights, age, destinations, flight_prices, hotel_prices)

        if ask_yes_no("Would you like to book this trip? Please answer y/n. --> "):
            print("Congratulations! Your trip is being booked.")
            break
        else:
            if not ask_yes_no("Would you like another suggestion? Please answer y/n. --> "):
                print("Goodbye and we hope to see you again soon!")
                break
    
    ask_to_create_account()
    print("Goodbye and we hope to see you again soon!")

if __name__ == "__main__":
    main()
