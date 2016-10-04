<issues>
<div class="authed-{ authed }">

<button onclick="{onSave}">保存</button>
<button onclick="{onConfirm}">予定通り完了</button>
<div each={ categoryKey, i in issueCategoryKeys }>
  <h3>{ issueCategory[categoryKey].categoryName }</h3>

  <ul>
    <li>現在 { performances[categoryKey].myPageNo } ページまで完了済み</li>
    <li>今週
      <select onchange="{ onFinishPageChanged }" data-category-key="{ categoryKey }">
        <option each="{ item in finishPagePulldownValues[categoryKey] }" selected="{ item.selected }">{ item.value }</option>
      </select> ページまでやる予定、今週やるページは... <span class="planPage" each={ v in planPageValues[categoryKey] } >{ v }, </span>
    </li>
  </ul>

  <table class="DataTable">
    <tr>
      <th>学校の進捗</th>
      <th>お題</th>
      <th>開始 〜 終了ページ</th>
      <th>ページ数</th>
      <th>達成度</th>
    </tr>
    <tr each={ issue, i in issueCategory[categoryKey].issues } class="active-{issue.schoolActive}">
      <td><input type="checkbox" class="schoolPageNoCheckbox" checked="{issue.schoolActive}" data-school-page-no="{ issue.pageRange.to }" data-category-key="{ categoryKey }" onchange="{onSchoolPageNoCheckboxChanged}"/></td>
      <td>{ issue.issueName }</td>
      <td>{ issue.pageRange.from } 〜 { issue.pageRange.to } ページ</td>
      <td>{ issue.pageCount } ページ</td>
      <td>{ issue.finishPercent }%</td>
    </tr>
  </table>
</div>
</div>

<script>
var self = this;

watch(function(){
  self.authed = window.state.authed;
  if(window.state.authed === 'Y'){
    self.update();
    return false;
  }
});

function watch(cb){
  var exec = cb();
  if(exec !== false){
    setTimeout(function(){
      watch(cb);
    }, 1000);
  }
}

self.issueCategoryKeys = ['math', 'lang'];
self.performances = {};
self.issueCategory = {};
self.finishPagePulldownValues = {};
self.planPageValues = {};
self.issueCategoryKeys.forEach(function(categoryKey){
  fetchPerformance(categoryKey, function(){
    self.update();
  });
});

self.onSave = function(){
  saveData();
}

self.onSchoolPageNoCheckboxChanged = function(event){
  adjustSchoolPageNo(event.target);
  self.update();
}

self.onFinishPageChanged = function(evnet){
  var categoryKey = event.target.getAttribute('data-category-key');
  var performance = self.performances[categoryKey];
  performance.myPlanPageNo = event.target.options[event.target.options.selectedIndex].value;
  prepareData(categoryKey, function(){
    self.update();
  });
}

self.onConfirm = function(){
  self.issueCategoryKeys.forEach(function(categoryKey){
    var performance = self.performances[categoryKey];
    performance.myPageNo = performance.myPlanPageNo;
    prepareData(categoryKey);
  });
  saveData();
}



function fetchPerformance(categoryKey, cb){
  firebase.database().ref('performance/' + categoryKey).on('value', function(result) {
    self.performances[categoryKey] = result.val();
    fetchIssues(categoryKey, cb);
  });
}

function fetchIssues(categoryKey, cb){
  firebase.database().ref('issueCategory/' + categoryKey).on('value', function(result){
    self.issueCategory[categoryKey] = result.val();
    prepareData(categoryKey, cb);
  });
}

function prepareData(categoryKey, cb){
  var performance = self.performances[categoryKey];
  if(!performance.myPlanPageNo){
    performance.myPlanPageNo = performance.myPageNo;
  }
  performance.myPlanPageNo = +performance.myPlanPageNo
  performance.myPageNo = +performance.myPageNo;
  var issues = self.issueCategory[categoryKey].issues;
  issues.forEach(function(issue){
    issue.pageCount = issue.pageRange.to - issue.pageRange.from + 1;
    issue.finishPage = performance.myPlanPageNo - issue.pageRange.from + 1;
    issue.finishPercent = issue.finishPage / issue.pageCount * 100;
    if(issue.finishPercent > 100){
      issue.finishPercent = 100;
    }
    if(issue.finishPercent < 0) issue.finishPercent = 0;
    issue.schoolActive = performance.schoolPageNo >= issue.pageRange.from;

    // 科目毎の総ページ数
    performance.pageCount = issue.pageRange.to;
  });

  self.planPageValues[categoryKey] = [];
  for(var i = performance.myPageNo + 1; i <= performance.myPlanPageNo; i++){
    self.planPageValues[categoryKey].push(i);
  }

  self.finishPagePulldownValues[categoryKey] = [];
  for(var i = 0; i <= performance.pageCount; i++){
    if(i >= performance.myPageNo){
      self.finishPagePulldownValues[categoryKey].push({
        value: i,
        selected: +performance.myPlanPageNo === i
      });
    }
  }
  if(cb) cb();
}

function adjustSchoolPageNo(currentCheckbox){
  var checkboxes = document.querySelectorAll('.schoolPageNoCheckbox');

  self.issueCategoryKeys.forEach(function(categoryKey){
    self.performances[categoryKey].schoolPageNo = 0;
  });

  Array.prototype.forEach.call(checkboxes, function(node) {
    var schoolPageNo = +node.getAttribute('data-school-page-no');
    var categoryKey = node.getAttribute('data-category-key');
    if(node.checked){
      self.performances[categoryKey].schoolPageNo = schoolPageNo;
    }
  });
  self.issueCategoryKeys.forEach(function(categoryKey){
    prepareData(categoryKey);
  });
}

function saveData(){
  firebase.database().ref('issueCategory').set(self.issueCategory).then(function(){
    firebase.database().ref('performance').set(self.performances).then(function(){
    });
  });
}
</script>

<style scoped>

h3{
  margin-top: 2em;
  border-bottom: solid 1px #eee;
}
.planPage{
  color: #ff5577;
}

.authed-N{
  display: none;
}

.DataTable{
  width: 90%;
}
.DataTable td{
  color: #ccc;
}
.DataTable .active-true td{
  color: #000;
}

table{
  background-color: #eee;
}
th{
  font-size: 13px;
}
td{
  padding: 4px;
  background-color: #fff;
  font-size: 13px;
}

</style>

</issues>
