package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Comment;

public interface ICommentService {


	    Comment addComment(Long userId, Long activityId, String content, float rating);
	    
	    Comment updateComment(Long commentId, String newContent, float newRating);
	    
	    boolean deleteComment(Long commentId);
	    
	    List<Comment> getCommentsByActivity(Long activityId);
	    
	    
	}



