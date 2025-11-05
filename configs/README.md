# Scanner Configuration Files

This directory contains configuration files for different scanner types used in the benchmark dataset.

## Available Configurations

### avia.env
**Scanner:** DJI Livox AVIA solid-state LiDAR  
**Topic:** `/livox/pointcloud`  
**Locations:** All 9 locations (72 total sequences when combined with all scanners)

### conslam.env
**Dataset:** ConSLAM (separate dataset, different topic structure)  
**Topic:** `pp_points/synced2rgb`  
**Note:** This is for the ConSLAM dataset, not part of the main 72 sequences

## Adding New Scanner Configurations

To add support for a new scanner type:

1. Create a new `.env` file named after the scanner (e.g., `hesai-big.env`)
2. Set the appropriate `INPUT_TOPIC` for that scanner
3. Configure other parameters as needed

### Template

```bash
# Configuration for [Scanner Name]
INPUT_TOPIC=/your/topic/name
OUTPUT_DIR=results-genz-icp
RECORD_TOPICS="/genz/local_map /genz/odometry"
```

**Note:** Only scanner-specific parameters are stored in configs. Common parameters like `ROS_DOMAIN_ID`, `STARTUP_TIMEOUT`, and `visualize` are hardcoded in `docker-compose.yml` for simplicity.

## Scanner Types in Benchmark

The main benchmark has 8 scanner types across 9 locations (72 total):

- **AVIA**        ✅ (avia.env) - `/livox/pointcloud`
- **Hesai Big**   ⏳ (needs topic name)
- **Hesai Small** ⏳ (needs topic name)
- **Livox HAP**   ✅ (avia.env) - `/livox/pointcloud`
- **MID ARM**     ✅ (avia.env) - `/livox/pointcloud`
- **MID STICK**   ✅ (avia.env) - `/livox/pointcloud`
- **Ouster**      ⏳ (needs topic name)
- **SICK**        ⏳ (needs topic name)

To complete the setup, identify the topic names for each scanner type and create corresponding config files.

