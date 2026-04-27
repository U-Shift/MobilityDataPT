import requests
import json
import datetime
import time

# Global variables as requested
BASE_URL = "https://services7.arcgis.com/VI34LdaZXM3uSRIn/arcgis/rest/services/Lugares/FeatureServer/0/query"
BATCH_SIZE = 2000
TOTAL_RECORDS = 122964

def scrape_emel_lugares():
    """
    Scrapes all records from the EMEL Lugares FeatureServer and exports them as a GeoJSON file.
    """
    all_features = []
    offset = 0
    
    print(f"Starting scrape for approximately {TOTAL_RECORDS} records...")
    
    # Session for connection pooling
    session = requests.Session()
    
    while offset < TOTAL_RECORDS:
        params = {
            "f": "geojson",
            "where": "1=1",
            "outFields": "*", # Use attributes separated by comma to reduce output size
            "resultOffset": offset,
            "resultRecordCount": BATCH_SIZE,
            "returnGeometry": "true"
        }
        
        try:
            response = session.get(BASE_URL, params=params)
            response.raise_for_status()
            data = response.json()
            
            features = data.get("features", [])
            if not features:
                print(f"No more features found at offset {offset}. Stopping.")
                break
                
            all_features.extend(features)
            print(f"Fetched {len(all_features)} records (last offset: {offset})...")
            
            # If we got fewer than BATCH_SIZE, we reached the end
            if len(features) < BATCH_SIZE:
                print("Reached the end of the records.")
                break
                
            offset += BATCH_SIZE
            # Small delay to be polite to the server
            time.sleep(0.2)
            
        except Exception as e:
            print(f"Error occurred at offset {offset}: {e}")
            # Optional: retry logic could be added here
            break

    # Construct final GeoJSON object
    geojson_output = {
        "type": "FeatureCollection",
        "features": all_features
    }
    
    # Generate filename with current date
    date_str = datetime.datetime.now().strftime("%Y%m%d")
    filename = f"experiments/emel_lugares_{date_str}.geojson"
    
    print(f"Saving {len(all_features)} records to {filename}...")
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(geojson_output, f, ensure_ascii=False)
        
    print(f"Success! Data exported to {filename}")

if __name__ == "__main__":
    # Scrap https://services7.arcgis.com/VI34LdaZXM3uSRIn/arcgis/rest/services/Lugares/FeatureServer/0/query?f=geojson&resultOffset=0&resultRecordCount=2000&where=1=1
    # Starting with an offset of 0 and considering that the API has a limit of 2000 records, get all 122 964 records.
    # Define the url and numbers as global variables, to enable code reusage
    # Export as a single geojson file called emel_lugares_<date>.geojson
    scrape_emel_lugares()
