import redis
import psycopg2
import json
import time
import os

# Wait for services to be ready
def wait_for_services():
    max_retries = 30
    for i in range(max_retries):
        try:
            # Test Redis connection
            r = redis.Redis(host="redis", db=0, socket_timeout=5)
            r.ping()
            print("✅ Redis is ready")
            
            # Test PostgreSQL connection
            conn = psycopg2.connect(
                host="postgres",
                database="votes",
                user="postgres", 
                password="postgres"
            )
            conn.close()
            print("✅ PostgreSQL is ready")
            return True
            
        except Exception as e:
            print(f"⏳ Waiting for services... ({i+1}/{max_retries})")
            time.sleep(2)
    
    raise Exception("Services not ready after maximum retries")

def main():
    print("🔧 Worker service starting...")
    
    # Wait for services
    wait_for_services()
    
    # Connect to services
    redis_conn = redis.Redis(host="redis", db=0, socket_timeout=5)
    
    while True:
        try:
            # Connect to PostgreSQL
            pg_conn = psycopg2.connect(
                host="postgres",
                database="votes", 
                user="postgres",
                password="postgres"
            )
            pg_conn.autocommit = True
            cursor = pg_conn.cursor()
            
            print("📡 Worker ready - processing votes...")
            
            # Process votes from Redis queue
            while True:
                try:
                    # Get vote from Redis queue (blocking)
                    raw_vote = redis_conn.blpop(['votes'], timeout=1)
                    
                    if raw_vote:
                        vote_data = json.loads(raw_vote[1])
                        voter_id = vote_data['voter_id']
                        vote = vote_data['vote']
                        
                        print(f"Processing vote: {vote} from voter {voter_id[:8]}...")
                        
                        # Store in PostgreSQL
                        cursor.execute(
                            "INSERT INTO votes (vote) VALUES (%s)",
                            (vote,)
                        )
                        
                        print(f"✅ Vote stored: {vote}")
                        
                except redis.RedisError as e:
                    print(f"❌ Redis error: {e}")
                    time.sleep(1)
                except psycopg2.Error as e:
                    print(f"❌ PostgreSQL error: {e}")
                    pg_conn = psycopg2.connect(
                        host="postgres",
                        database="votes",
                        user="postgres", 
                        password="postgres"
                    )
                    pg_conn.autocommit = True
                    cursor = pg_conn.cursor()
                    
        except Exception as e:
            print(f"❌ Worker error: {e}")
            time.sleep(5)

if __name__ == "__main__":
    main()
