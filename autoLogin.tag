<autoLogin>
<div><p>{ info }</p></div>
<script>
var self = this;
self.info = 'ログイン中...';
var authCheckFlg = sessionStorage.authCheckFlg;
if(authCheckFlg){
  sessionStorage.removeItem('authCheckFlg');
}

// Google プロバイダ オブジェクトのインスタンスを作成
self.provider = new firebase.auth.GoogleAuthProvider();

// ログインリダイレクト先でのログイン結果を取得する
firebase.auth().getRedirectResult().then(function(result) {

  // リダイレクト先でログインしてればuser情報が取れる
  if(result.user){
    window.state.authed = 'Y';
    self.info = result.user.email;
    self.update();
  }
  else{
    // 初回はここがtrueになる
    if(!authCheckFlg){

      // 次回はここにこないようにする
      sessionStorage.authCheckFlg = 'Y';

      // ログインページにリダイレクトしてログインを行う
      firebase.auth().signInWithRedirect(self.provider);
    }
  }
}).catch(function(error) {
});
</script>
</autoLogin>
