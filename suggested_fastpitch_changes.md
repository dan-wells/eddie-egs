# Suggested edits to FastPitch code

Some changes should be made to FastPitch code in either [evdv/FastPitches](https://github.com/evdv/FastPitches) or [NVIDIA/DeepLearningExamples](https://github.com/NVIDIA/DeepLearningExamples) for improved performance when running on Eddie.

## Reduce memory consumption in submitted jobs

Something about running `DataLoader` instances with `num_workers > 1` causes memory usage in submitted jobs to explode (for some reason it's not an issue in interactive sessions). It seems best to use 1 additional worker process for training data loading and 0 for validation.

This change is _definitely_ recommended to run anything on Eddie.

```diff
diff --git a/PyTorch/SpeechSynthesis/FastPitch/train.py b/PyTorch/SpeechSynthesis/FastPitch/train.py
index bda6680..8cabb7b 100644
--- a/PyTorch/SpeechSynthesis/FastPitch/train.py
+++ b/PyTorch/SpeechSynthesis/FastPitch/train.py
@@ -395,7 +395,7 @@ def validate(model, criterion, valset, batch_size, collate_fn, distributed_run,
     tik = time.perf_counter()
     with torch.no_grad():
         val_sampler = DistributedSampler(valset) if distributed_run else None
-        val_loader = DataLoader(valset, num_workers=4, shuffle=False,
+        val_loader = DataLoader(valset, num_workers=0, shuffle=False,
                                 sampler=val_sampler,
                                 batch_size=batch_size, pin_memory=False,
                                 collate_fn=collate_fn)
@@ -601,7 +601,7 @@ def main():
         train_sampler, shuffle = None, True

     # 4 workers are optimal on DGX-1 (from epoch 2 onwards)
-    train_loader = DataLoader(trainset, num_workers=4, shuffle=shuffle,
+    train_loader = DataLoader(trainset, num_workers=1, shuffle=shuffle,
                               sampler=train_sampler, batch_size=args.batch_size,
                               pin_memory=True, persistent_workers=True,
                               drop_last=True, collate_fn=collate_fn)
```

## Speed up pitch extraction

In `TTSDataset`, the [`librosa.pyin`](https://librosa.org/doc/0.9.1/generated/librosa.pyin.html) implementation of the probabilistic YIN algorithm is used for pitch extraction. This implementation is very slow, e.g. processing LJSpeech in around 12 hours!

### Reduce candidate pitch range

One option to speed this up without loss of accuracy is to reduce the range of pitch values considered as viable hypotheses (this range defines a Viterbi search space in pYIN), for example from the default range 65--2093 Hz to something more appropriate for human speech, such as 40--600 Hz. This should speed things up a bit, but it will probably still take a couple hours to get through LJSpeech.

```diff
diff --git a/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py b/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
index a007db8..fa3bfb4 100644
--- a/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
+++ b/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
@@ -90,7 +90,8 @@ def estimate_pitch(wav, mel_len, method='pyin', normalize_mean=None,
     if method == 'pyin':

         snd, sr = librosa.load(wav)
         pitch_mel, voiced_flag, voiced_probs = librosa.pyin(
-            snd, fmin=librosa.note_to_hz('C2'),
-            fmax=librosa.note_to_hz('C7'), frame_length=1024)
+            snd, fmin=40, fmax=600, frame_length=1024)
         assert np.abs(mel_len - pitch_mel.shape[0]) <= 1.0
```

### Use non-probabilistic YIN algorithm

Another option is to use the non-probabilistic YIN algorithm instead. This could give slightly reduced accuracy (something like 95% correct pitch values vs. 99% with pYIN), but runs over LJSpeech in around 20 minutes. No reason not to combine this with the update pitch ranges suggested above!

```diff
diff --git a/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py b/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
index a007db8..fa3bfb4 100644
--- a/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
+++ b/PyTorch/SpeechSynthesis/FastPitch/fastpitch/data_function.py
@@ -90,7 +90,8 @@ def estimate_pitch(wav, mel_len, method='pyin', normalize_mean=None,
     if method == 'pyin':

         snd, sr = librosa.load(wav)
-        pitch_mel, voiced_flag, voiced_probs = librosa.pyin(
-            snd, fmin=librosa.note_to_hz('C2'),
-            fmax=librosa.note_to_hz('C7'), frame_length=1024)
+        pitch_mel = librosa.yin(
+            snd, fmin=40, fmax=600, frame_length=1024)
         assert np.abs(mel_len - pitch_mel.shape[0]) <= 1.0
```

A more comprehensive change would add this as an additional option alongside pYIN; this would need some additional changes to the `argparse` definitions for `--f0-method` in `prepare_dataset.py` and `--pitch-online-method` in `train.py`.
