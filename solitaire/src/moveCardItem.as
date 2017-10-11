package {

public class moveCardItem {
	public var card:Card
	public var startX:Number
	public var startY:Number
	public var endX:Number
	public var endY:Number
	public var delayX:Number
	public var delayY:Number
	public var totalCount:Number
	public var maxCount:int
public function moveCardItem(card:Card, startX:Number, startY:Number, endX:Number, endY:Number, delayX:Number, delayY:Number, totalCount:Number, maxCount:int) {
	this.card = card
	this.startX = startX
	this.startY = startY
	this.endX = endX
	this.endY = endY
	this.delayX = delayX
	this.delayY = delayY
	this.totalCount = totalCount
	this.maxCount = maxCount
}

}}