/*jshint multistr:true */

this.recline = this.recline || {};
this.recline.View = this.recline.View || {};

(function($, my) {
  "use strict";

my.RecordCount = Backbone.View.extend({
  className: 'recline-record-count',
  template: ' \
    <span class="count">{{recordCount}}</span> {{record}} \
  ',

  initialize: function() {
    _.bindAll(this, 'render');
    this.model.bind('query:done', this.render);
    this.render();
  },

  render: function() {
    var tmplData = this.model.toTemplateJSON();
    tmplData.recordCount = tmplData.recordCount || 'Unknown number of';
	if (tmplData.recordCount==1) {
      tmplData.record = 'record';
    } else {
      tmplData.record = 'records';
    }
    var templated = Mustache.render(this.template, tmplData);
    this.$el.html(templated);
  }
});

})(jQuery, recline.View);