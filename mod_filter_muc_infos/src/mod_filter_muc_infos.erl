%%%-------------------------------------------------------------------
%%% File    : mod_filter_muc_infos.erl
%%% Author  : Holger Weiss <holger@zedat.fu-berlin.de>
%%% Purpose : Filter certain MUC messages
%%% Created : 26 Jun 2015 by Holger Weiss <holger@zedat.fu-berlin.de>
%%%-------------------------------------------------------------------

-module(mod_filter_muc_infos).
-author('holger@zedat.fu-berlin.de').

-behaviour(gen_mod).

%% gen_mod callbacks.
-export([start/2, stop/1]).

%% ejabberd_hooks callbacks.
-export([strip_body_from_subject/5, drop_info_messages/1]).

-include("jlib.hrl").

-define(NOT_REGISTERED, <<"The nickname you are using is not registered">>).
-define(NOT_ANONYMOUS, <<"This room is not anonymous">>).

%% -------------------------------------------------------------------
%% gen_mod callbacks.
%% -------------------------------------------------------------------

-spec start(binary(), gen_mod:opts()) -> ok.

start(Host, Opts) ->
    case gen_mod:get_opt(strip_body_from_subject, Opts,
			 fun(B) when is_boolean(B) -> B end, true) of
      true ->
	  ejabberd_hooks:add(user_receive_packet, Host, ?MODULE,
			     strip_body_from_subject, 50);
      false ->
	  ok
    end,
    case gen_mod:get_opt(drop_info_messages, Opts,
			 fun(B) when is_boolean(B) -> B end, true) of
      true ->
	  ejabberd_hooks:add(filter_packet, ?MODULE,
			     drop_info_messages, 50);
      false ->
	  ok
    end.

-spec stop(binary()) -> ok.

stop(Host) ->
    ejabberd_hooks:delete(user_receive_packet, Host, ?MODULE,
			  strip_body_from_subject, 50),
    ejabberd_hooks:delete(filter_packet, ?MODULE,
			  drop_info_messages, 50).

%% -------------------------------------------------------------------
%% ejabberd_hooks callbacks.
%% -------------------------------------------------------------------

-spec drop_info_messages({jid(), jid(), xmlel()} | drop)
      -> {jid(), jid(), xmlel()} | drop.

drop_info_messages({#jid{lresource = <<"">>}, _To,
		    #xmlel{name = <<"message">>,
			   attrs = Attrs} = Message} = Acc) ->
    case fxml:get_attr(<<"type">>, Attrs) of
      {value, <<"groupchat">>} ->
	  case fxml:get_subtag(Message, <<"body">>) of
	    #xmlel{children = [{xmlcdata, ?NOT_REGISTERED}]} ->
		drop;
	    #xmlel{children = [{xmlcdata, ?NOT_ANONYMOUS}]} ->
		drop;
	    _ ->
		Acc
	  end;
      _ ->
	  Acc
    end;
drop_info_messages(Acc) -> Acc.

-spec strip_body_from_subject(xmlel(), term(), jid(), jid(), jid()) -> xmlel().

strip_body_from_subject(#xmlel{name = <<"message">>, attrs = Attrs} = Message,
			_C2SState, _JID, #jid{lresource = <<"">>}, _To) ->
    case fxml:get_attr(<<"type">>, Attrs) of
      {value, <<"groupchat">>} ->
	  case fxml:get_subtag(Message, <<"subject">>) of
	    #xmlel{} ->
		strip_body(Message);
	    _ ->
		Message
	  end;
      _ ->
	  Message
    end;
strip_body_from_subject(Stanza, _C2SState, _JID, _From, _To) -> Stanza.

%% -------------------------------------------------------------------
%% Internal functions.
%% -------------------------------------------------------------------

-spec strip_body(xmlel()) -> xmlel().

strip_body(#xmlel{children = Children} = Message) ->
    IsNotBody = fun(#xmlel{name = <<"body">>}) ->
			false;
		   (_) ->
			true
		end,
    Message#xmlel{children = lists:filter(IsNotBody, Children)}.
