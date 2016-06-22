p1_url = ''
p2_url = ''
Dropzone.autoDiscover = false;
#$('div#wrapper1').hide()
#$('div#wrapper2').hide()
$('.owl-carousel').hide()

$("div#upload1").dropzone
  url: '/upload'
  success: (f, response)->
    $('div#upload1').hide()
    p1_url = response
    $('#wrapper1 .network').css('background-image', 'url("' + p1_url + '")')
    $('div#wrapper1').show()
$("div#upload2").dropzone
  url: '/upload'
  success: (f, response)->
    $('div#upload2').hide()
    p2_url = response
    $('#wrapper2 .network').css('background-image', 'url("' + p2_url + '")')
    $('div#wrapper2').show()


clearPopUp1 = ->
  document.querySelector('#wrapper1 .saveButton').onclick = null;
  document.querySelector('#wrapper1 .cancelButton').onclick = null;
  document.querySelector('#wrapper1 .network-popUp').style.display = 'none';
saveData1 = (data, callback) ->
  data.id = document.querySelector('#wrapper1 .node-id').value;
  data.label = document.querySelector('#wrapper1 .node-label').value;
  clearPopUp1();
  callback(data);
cancelEdit1 = (callback) ->
  clearPopUp1();
  callback(null);

container1 = document.querySelector('#wrapper1 .network')
options1 =
  width: '600px'
  height: '800px'
  autoResize: false
  interaction:
    dragView: false
    zoomView: false
  manipulation:
    enabled: true
    initiallyActive: true
    addNode: (data, callback)->
      document.querySelector('#wrapper1 .operation').innerHTML = "Add Node";
      document.querySelector('#wrapper1 .node-id').value = data.id;
      document.querySelector('#wrapper1 .node-label').value = data.label;
      document.querySelector('#wrapper1 .saveButton').onclick = saveData1.bind(this, data, callback);
      document.querySelector('#wrapper1 .cancelButton').onclick = clearPopUp1.bind();
      document.querySelector('#wrapper1 .network-popUp').style.display = 'block';
    editNode: (data, callback) ->
      document.querySelector('#wrapper1 .operation').innerHTML = "Edit Node";
      document.querySelector('#wrapper1 .node-id').value = data.id;
      document.querySelector('#wrapper1 .node-label').value = data.label;
      document.querySelector('#wrapper1 .saveButton').onclick = saveData1.bind(this, data, callback);
      document.querySelector('#wrapper1 .cancelButton').onclick = cancelEdit1.bind(this, callback);
      document.querySelector('#wrapper1 .network-popUp').style.display = 'block';
    addEdge: false
    editEdge: true
    deleteNode: true
    deleteEdge: true
    controlNodeStyle: {}
  physics:
    enabled: false
  edges:
    smooth: false
    color:
      color: '#2B7CE9'
      highlight: '#2B7CE9'
      inherit: false
  nodes:
    shape: 'circle'

nodes1 = new vis.DataSet []
edges1 = new vis.DataSet []
data1 =
  nodes: nodes1
  edges: edges1
network1 = new vis.Network(container1, data1, options1);


clearPopUp2 = ->
  document.querySelector('#wrapper2 .saveButton').onclick = null;
  document.querySelector('#wrapper2 .cancelButton').onclick = null;
  document.querySelector('#wrapper2 .network-popUp').style.display = 'none';
saveData2 = (data, callback) ->
  data.id = document.querySelector('#wrapper2 .node-id').value;
  data.label = document.querySelector('#wrapper2 .node-label').value;
  clearPopUp2();
  callback(data);
cancelEdit2 = (callback) ->
  clearPopUp2();
  callback(null);

container2 = document.querySelector('#wrapper2 .network')
options2 =
  width: '600px'
  height: '800px'
  autoResize: false
  interaction:
    dragView: false
    zoomView: false
  manipulation:
    enabled: true
    initiallyActive: true
    addNode: (data, callback)->
      document.querySelector('#wrapper2 .operation').innerHTML = "Add Node";
      document.querySelector('#wrapper2 .node-id').value = data.id;
      document.querySelector('#wrapper2 .node-label').value = data.label;
      document.querySelector('#wrapper2 .saveButton').onclick = saveData2.bind(this, data, callback);
      document.querySelector('#wrapper2 .cancelButton').onclick = clearPopUp2.bind();
      document.querySelector('#wrapper2 .network-popUp').style.display = 'block';
    editNode: (data, callback) ->
      document.querySelector('#wrapper2 .operation').innerHTML = "Edit Node";
      document.querySelector('#wrapper2 .node-id').value = data.id;
      document.querySelector('#wrapper2 .node-label').value = data.label;
      document.querySelector('#wrapper2 .saveButton').onclick = saveData2.bind(this, data, callback);
      document.querySelector('#wrapper2 .cancelButton').onclick = cancelEdit2.bind(this, callback);
      document.querySelector('#wrapper2 .network-popUp').style.display = 'block';
    addEdge: false
    editEdge: true
    deleteNode: true
    deleteEdge: true
    controlNodeStyle: {}
  physics:
    enabled: false
  edges:
    smooth: false
    color:
      color: '#2B7CE9'
      highlight: '#2B7CE9'
      inherit: false
  nodes:
    shape: 'circle'

nodes2 = new vis.DataSet []
edges2 = new vis.DataSet []
data2 =
  nodes: nodes2
  edges: edges2
network2 = new vis.Network(container2, data2, options2);


$('#morph').on 'click', ->
  label1 = new Object()
  for i in nodes1.get()
    label1[i.label] = [i.x, i.y]
  label2 = new Object()
  for i in nodes2.get()
    label2[i.label] = [i.x, i.y]
  result1 = []
  result2 = []
  for i,v of label1
    result1.push(label1[i])
    result2.push(label2[i])

  $.ajax
    url: '/morph'
    type: 'post'
    contentType: 'application/json'
    dataType: 'json'
    data: JSON.stringify
      points1: result1
      points2: result2
      pictures: [p1_url, p2_url]
    success: (data)->
      console.log(data)
      $('.wrapper').hide()
      $('#morph').hide()
      owl = $('.owl-carousel')
      for p_url in data['result']
        owl.append('<img class="item" src="' + p_url + '">')
      owl.show()
      owl.owlCarousel
        items: 10
        lazyLoad: true
        loop: false
        margin: 10
        center: true
        autoWidth: true
      owl.on 'mousewheel', '.owl-stage', (e)->
        if (e.deltaY < 0)
          owl.trigger('next.owl');
        else
          owl.trigger('prev.owl');
        e.preventDefault();

