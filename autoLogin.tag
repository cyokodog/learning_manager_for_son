<autoLogin>
<div><p>{ info }</p></div>
<script>
var self = this;

// sessionStorageにログイン情報があればログイン済み
if(sessionStorage.user){

  // ログインユーザ情報を更新する
  updateAuthedInfo(sessionStorage.user);
}
else{

  // ログイン処理
  login();
}

// ログイン処理
function login(){
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
      updateAuthedInfo(result.user.email);
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
}

// ログインユーザ情報を更新する
function updateAuthedInfo(user){
  if(window.state){
    window.state.authed = 'Y';
  }
  self.info = user;
  sessionStorage.user = user;
  self.update();
}

</script>
</autoLogin>
