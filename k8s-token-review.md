submit to token review endpoint with a valid token (replace `xyz` with a token which has the `system:auth-delegator` role.

`curl -v http://your-kube-api-server:6443/apis/authentication.k8s.io/v1/tokenreviews -X POST -H 'Content-Type: application/json; chatset=utf-8' -H 'Authorization: Bearer xyz' -d @k8s-token-review.json`

```
{
  "kind": "TokenReview",
  "apiVersion": "authentication.k8s.io/v1",
  "metadata": {
    "creationTimestamp": null
  },
  "spec": {
    "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ii1Qc1diYk5YTXBzR09qY3JXbmRvUnZfX24xNkJEZDRxWjZuVDZONzA0VzgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InZhdWx0LWF1dGgtdG9rZW4tOHdwNmsiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoidmF1bHQtYXV0aCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImM1NjAzNTM5LTI1MmUtNDI3OS04NzM0LThiN2YyMGZiMjU3NCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnZhdWx0LWF1dGgifQ.ANFfQF5c04sVdlxIGwWgauF_LCVsUD3vFSB5JAjFecYoDF3nn0kQkj70PU3N9ANIFdADZj24HsfR3fqbGv7s0E3sDj835xB4U5drE0u9FoldQAIgdd05zYVYA6jVM-nyDr5xMemo1iK0itL6IiBEPI66qNCMHKseTv2pk2L6ivgUG7UmjMNVnF7RaVEsiEkD6Mx03fIFyA9mAOOX3_xoakUbAwLroeyXRtBC6Ax7F3wgf8RNHrSzOPjIpcs6VrbgtOG0KxVAuaKgKDtsXguOcN6vFo3JNTkQNn_--cn31MMmud-p3V9eZKXPjP5Ou0WGPp_B9scWlPffhD0i9W5TIA"
  },
  "status": {
    "user": {}
  }
}
```
