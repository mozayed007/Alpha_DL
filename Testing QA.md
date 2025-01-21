Here's a comprehensive testing plan to verify all critical functionality of the script:

1. **Basic Setup Tests**:
```text
- Run script for first time to check initialization
- Verify all dependencies are detected (yt-dlp, ffmpeg, aria2c, ytarchive)
- Check if download directory is created properly
- Verify hardware acceleration detection works
```

2. **Single Video Download Tests**:
```text
Test URLs:
- Regular video: https://www.youtube.com/watch?v=jNQXAC9IVRw (First YouTube video)
- High quality video: Any 4K video
- Test all quality options (Best/1080p/720p)
- Test with hardware acceleration ON/OFF
```

3. **Playlist Download Tests**:
```text
Test URLs:
- Short playlist (2-3 videos)
- Longer playlist (10+ videos)
- Test concurrent downloads
- Verify folder structure
```

4. **Audio Download Tests**:
```text
- Single audio extraction (all formats: MP3/M4A/WAV/OPUS)
- Playlist audio extraction
- Verify metadata and thumbnails are embedded
```

5. **Live Stream Tests**:
```text
Test both methods:
a) YTArchive:
   - Scheduled stream (wait function)
   - Ongoing stream
   - VOD after stream ends
   
b) YT-DLP:
   - Completed stream/VOD
   - Stream with chapters
```

6. **Channel Download Tests**:
```text
- Small channel (few videos)
- Test with video limit
- Test archive functionality
- Test resume capability
```

7. **Concurrent Operation Tests**:
```text
- Run multiple instances simultaneously:
  * Video download + Audio download
  * Playlist download + Live stream
  * Multiple single video downloads
  * Multiple playlist downloads
```

8. **Feature Toggle Tests**:
```text
- Test SponsorBlock toggle
- Test subtitle embedding
- Test thumbnail embedding
- Test metadata embedding
- Test aria2c integration
```

9. **Error Handling Tests**:
```text
- Invalid URLs
- Private videos
- Deleted videos
- Network interruption
- Disk space full
- Invalid quality selection
```

10. **Hardware Acceleration Tests**:
```text
- Test with NVIDIA GPU
- Test with Intel QuickSync
- Test with AMD GPU
- Test fallback to CPU
- Test switching between modes
```

Test Command Examples:
```text
REM Test 1: Basic video download
Alpha_util.bat
Select: 1 (Single Video)
URL: https://www.youtube.com/watch?v=jNQXAC9IVRw
Quality: 1 (Best)

REM Test 2: Concurrent downloads
Open 3 CMD windows
Run Alpha_util.bat in each
Download different content types simultaneously

REM Test 3: Live stream
Find an active livestream
Use option 5
Test both ytarchive and yt-dlp methods

REM Test 4: Audio extraction
Select: 4 (Audio Only)
Test all formats (MP3/M4A/WAV/OPUS)
```

Monitoring Points:
1. Check CPU/GPU usage during downloads
2. Monitor temp directory cleanup
3. Verify file integrity after downloads
4. Check concurrent download performance
5. Verify hardware acceleration is working
6. Check memory usage during operations

Would you like me to provide more specific test cases or focus on any particular area?
