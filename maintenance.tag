<maintenance>
<div class="authed-{ authed }">

<button onclick="{onSave}">保存</button>

<div each={ categoryKey, i in issueCategoryKeys }>
  <h3>{ issueCategory[categoryKey].categoryName }</h3>



  <table class="DataTable">
    <tr>
      <th>お題</th>
      <th>ページ範囲</th>
    </tr>
    <tr each={ issue, i in issueCategory[categoryKey].issues } class="active-{issue.schoolActive}">
      <td><input class="issueName" value="{issue.issueName}" name="issueName" categoryKey={categoryKey} orderNo={i} oninput="{onIssueChanged}"/></td>
      <td>
        <input value="{issue.pageRange.from}" group="pageRange" name="from" categoryKey={categoryKey} orderNo={i} oninput="{onIssueChanged}"/>
        〜
        <input value="{issue.pageRange.to}" group="pageRange" name="to" categoryKey={categoryKey} orderNo={i} oninput="{onIssueChanged}"/> ページ
      </td>
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

self.issueCategoryKeys = ['math', 'lang', 'science', 'society'];
self.performances = {};
self.issueCategory = {};
self.finishPagePulldownValues = {};
self.planPageValues = {};
self.issueCategoryKeys.forEach(function(categoryKey){
  fetchPerformance(categoryKey, function(){

    var issues = self.issueCategory[categoryKey].issues;
    issues.push({pageRange:{}});
    self.update();
  });
});

self.onSave = function(){
  saveData();
}






self.onIssueChanged = function(event){

  var target = event.target;
console.log(event);
  var categoryKey = target.getAttribute('categoryKey');
  var orderNo = target.getAttribute('orderNo');
  var group = target.getAttribute('group');
  var name = target.getAttribute('name');
//  var issue = self.issueCategory[categoryKey].issues[orderNo];
  var issue = event.item.issue;


console.log('group',group);

if(group){
  issue[group] = issue[group] || {};
  issue[group][name] = target.value;;
}
else{
  issue[name] = target.value;;
}

//  issue.issueName = target.value;


};



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
console.log('save',self.issueCategory);


//    firebase.database().ref('performance').set(self.performances).then(function(){
//    });
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

</maintenance>
