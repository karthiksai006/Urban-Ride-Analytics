import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
   password=os.getenv("MYSQL_PASSWORD", "your_password_here"),
    database="ride_dw"
)

cursor = conn.cursor()
print("Connected!")
#-------- Data insertion --------
import pandas as pd

df = pd.read_csv("final_rides_data.csv")

# TIME
dim_time = df[['DateTime','Hour','Day','Month','Weekday','Is_Weekend','Time_Slot']].drop_duplicates().reset_index(drop=True)
dim_time['time_id'] = dim_time.index + 1

# LOCATION
dim_location = df[['City','Pickup_Location','Drop_Location']].drop_duplicates().reset_index(drop=True)
dim_location['location_id'] = dim_location.index + 1

# VEHICLE
dim_vehicle = df[['Vehicle_Type']].drop_duplicates().reset_index(drop=True)
dim_vehicle['vehicle_id'] = dim_vehicle.index + 1

# PAYMENT
dim_payment = df[['Payment_Method']].drop_duplicates().reset_index(drop=True)
dim_payment['payment_id'] = dim_payment.index + 1

# STATUS
dim_status = df[['Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                 'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                 'Incomplete_Rides','Incomplete_Reason']].drop_duplicates().reset_index(drop=True)
dim_status['status_id'] = dim_status.index + 1

#---------------------

df = df.merge(dim_time, on=['DateTime','Hour','Day','Month','Weekday','Is_Weekend','Time_Slot'])
df = df.merge(dim_location, on=['City','Pickup_Location','Drop_Location'])
df = df.merge(dim_vehicle, on=['Vehicle_Type'])
df = df.merge(dim_payment, on=['Payment_Method'])
df = df.merge(dim_status, on=['Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                             'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                             'Incomplete_Rides','Incomplete_Reason'])


#-----------

fact = df[['Booking_ID','time_id','location_id','vehicle_id','payment_id','Customer_ID',
           'Ride_Distance','Booking_Value','Driver_Rating','Customer_Rating',
           'VTAT','CTAT','status_id']]

fact.columns = ['booking_id','time_id','location_id','vehicle_id','payment_id','customer_id',
                'ride_distance','booking_value','driver_rating','customer_rating',
                'vtat','ctat','status_id']


#------ sql connection
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password=os.getenv("MYSQL_PASSWORD", "your_password_here"),
    database="ride_dw"
)

cursor = conn.cursor()

# data insertion------------------
# FIX ORDER

dim_time = dim_time[['time_id','DateTime','Hour','Day','Month','Weekday','Is_Weekend','Time_Slot']]

dim_location = dim_location[['location_id','City','Pickup_Location','Drop_Location']]

dim_vehicle = dim_vehicle[['vehicle_id','Vehicle_Type']]

dim_payment = dim_payment[['payment_id','Payment_Method']]

dim_status = dim_status[['status_id','Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                         'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                         'Incomplete_Rides','Incomplete_Reason']]


cursor.executemany("""
INSERT INTO dim_time (time_id, DateTime, Hour, Day, Month, Weekday, Is_Weekend, Time_Slot)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
""", dim_time.values.tolist())

conn.commit()
print("dim_time done")

dim_location = dim_location[['location_id','City','Pickup_Location','Drop_Location']]

cursor.executemany("""
INSERT INTO dim_location VALUES (%s,%s,%s,%s)
""", dim_location.values.tolist())

conn.commit()
print("dim_location done")

cursor.executemany("""
INSERT INTO dim_location VALUES (%s,%s,%s,%s)
""", dim_location.values.tolist())

conn.commit()
print("dim_location done")

dim_vehicle = dim_vehicle[['vehicle_id','Vehicle_Type']]

cursor.executemany("""
INSERT INTO dim_vehicle VALUES (%s,%s)
""", dim_vehicle.values.tolist())

conn.commit()
print("dim_vehicle done")


dim_payment = dim_payment[['payment_id','Payment_Method']]

cursor.executemany("""
INSERT INTO dim_payment VALUES (%s,%s)
""", dim_payment.values.tolist())

conn.commit()
print("dim_payment done")


dim_status = dim_status[['status_id','Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                         'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                         'Incomplete_Rides','Incomplete_Reason']]


cursor.executemany("""
INSERT INTO dim_status VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
""", dim_status.values.tolist())

conn.commit()
print("dim_status done")

dim_status = dim_status.where(pd.notnull(dim_status), None)
print(dim_status.isnull().sum())


cursor.executemany("""
INSERT INTO dim_status VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
""", dim_status.values.tolist())

conn.commit()
print("dim_status done")

dim_status = dim_status.where(pd.notnull(dim_status), None)

dim_status = dim_status.astype(object)

dim_status = dim_status.where(pd.notnull(dim_status), None)

data = [
    tuple(None if pd.isna(x) else x for x in row)
    for row in dim_status.values
]

cursor.executemany("""
INSERT INTO dim_status VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
""", data)

conn.commit()
print("dim_status done")


df = df.merge(dim_time, on=['DateTime','Hour','Day','Month','Weekday','Is_Weekend','Time_Slot'])
df = df.merge(dim_location, on=['City','Pickup_Location','Drop_Location'])
df = df.merge(dim_vehicle, on=['Vehicle_Type'])
df = df.merge(dim_payment, on=['Payment_Method'])
df = df.merge(dim_status, on=['Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                             'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                             'Incomplete_Rides','Incomplete_Reason'])


print(df[['time_id','location_id','vehicle_id','payment_id','status_id']].head())

print(df.columns)


df = df.merge(dim_time, on=['DateTime','Hour','Day','Month','Weekday','Is_Weekend','Time_Slot'])
df = df.merge(dim_location, on=['City','Pickup_Location','Drop_Location'])
df = df.merge(dim_vehicle, on=['Vehicle_Type'])
df = df.merge(dim_payment, on=['Payment_Method'])
df = df.merge(dim_status, on=['Booking_Status','Cancelled_By_Customer','Cancelled_By_Driver',
                             'Cancellation_Reason_Customer','Cancellation_Reason_Driver',
                             'Incomplete_Rides','Incomplete_Reason'])


print(df.columns)


print(df[['time_id','location_id','vehicle_id','payment_id','status_id']].head())


print(df.columns)
print(dim_time.columns)



fact = df[['Booking_ID','time_id','location_id','vehicle_id','payment_id','Customer_ID',
           'Ride_Distance','Booking_Value','Driver_Rating','Customer_Rating',
           'VTAT','CTAT','status_id']]

fact.columns = ['booking_id','time_id','location_id','vehicle_id','payment_id','customer_id',
                'ride_distance','booking_value','driver_rating','customer_rating',
                'vtat','ctat','status_id']


print(fact.head())
print(fact.shape)

fact = fact.astype(object)
fact = fact.where(pd.notnull(fact), None)


fact_data = [
    tuple(None if pd.isna(x) else x for x in row)
    for row in fact.values
]


cursor.executemany("""
INSERT INTO fact_bookings VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
""", fact_data)

conn.commit()
print("fact_bookings done")



cursor.executemany("""
INSERT INTO fact_bookings VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
""", fact_data)

conn.commit()
print("fact_bookings done")


cursor.executemany("""
INSERT INTO fact_bookings (
    booking_id, time_id, location_id, vehicle_id, payment_id, customer_id,
    ride_distance, booking_value, driver_rating, customer_rating,
    vtat, ctat, status_id
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
""", fact_data)

conn.commit()
print("fact_bookings done")