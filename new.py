import sys
from confluent_kafka import Producer
import socket
from concurrent.futures import ThreadPoolExecutor
import threading
import time

# Kafka configuration with TLS
conf = {
    'bootstrap.servers': '192.168.0.241:9093',
    'security.protocol': 'SASL_PLAINTEXT',  # Use SSL for security
    'sasl.mechanism': 'SCRAM-SHA-512',
    'sasl.username': 'yukinoli',
    'sasl.password': 'Oh7AZ8MxiSO3ZkVterLhMelQfMCgY3ca'
}

# Topic to which you want to send messages
topic = 'tutorial-topic'  # Replace with your Kafka topic


# Create the Kafka producer (thread-safe)
producer = Producer(conf)

# Callback function to confirm delivery
def delivery_callback(err, msg):
    if err:
        print(f"Error delivering message: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")



# Function to send messages in an infinite loop
def send_messages_continuously(thread_id):
    counter = 0
    while True:
        message = f"Message from thread {thread_id}: {counter}"
        try:
            producer.produce(topic, message.encode('utf-8'), callback=delivery_callback)
            producer.poll(0)  # Process delivery events
            counter += 1
            # Optional: Add a small delay to prevent overload
            time.sleep(0.1)  # 100 ms between messages
        except Exception as e:
            print(f"Error sending message in thread {thread_id}: {e}")
            time.sleep(1)  # Wait before retrying

# Number of threads you want to use
num_threads = 5  # Adjust this value according to your needs and available resources

def main():
    # Use ThreadPoolExecutor to handle multiple threads
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        # Submit a task for each thread
        for i in range(num_threads):
            executor.submit(send_messages_continuously, i)
        
        try:
            # Keep the main thread active
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("Interrupted by user. Closing producers...")
        finally:
            # Ensure all messages have been delivered
            producer.flush()
            print("All messages have been sent.")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
