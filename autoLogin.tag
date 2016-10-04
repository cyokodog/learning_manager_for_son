<autoLogin>
<div><p>{ info }</p></div>
<script>
var self = this;
self.info = 'ログイン中...';
var authCheckFlg = sessionStorage.authCheckFlg;
if(authCheckFlg){
  sessionStorage.removeItem('authCheckFlg');
}
self.provider = new firebase.auth.GoogleAuthProvider();
firebase.auth().getRedirectResult().then(function(result) {
  if(result.user){
    self.info = result.user.email;
    self.update();
  }
  else{
    if(!authCheckFlg){
      sessionStorage.authCheckFlg = 'Y';
      firebase.auth().signInWithRedirect(self.provider);
    }
  }
}).catch(function(error) {
});
</script>
</autoLogin>
